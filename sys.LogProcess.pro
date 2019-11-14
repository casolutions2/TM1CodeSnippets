# =============================================================================
#   PROLOG
# =============================================================================

# =============================================================================
#   DESCRIPTION 
#   Purpose:        To log process events
#   Date Created:   2019-11-11
#   Author:         Craig Sawers
# =============================================================================

# =============================================================================
#   PARAMETERS
#   pEntryType  - Numeric   - 0=Error, 1=Start, 2=End, 3=TrxCount
#   pProcess    - String    - Process Name
#   pStartTime  - Numeric   - value of the attribute that is to be used to determine lock status
#   pValue      - String    - Value to be entered to cube
# =============================================================================

# =============================================================================
#   CHANGE LOG
# =============================================================================

if ( Long(pProcess) = 0 );
    ItemReject( 'Process cannot be blank' );
    ProcessError;
endif;
if ( pStartTime = 0 );
    ItemReject( 'StartTime cannot be blank');
endif;

# =============================================================================
#   VARIABLES and CONSTANTS
# =============================================================================
vnStartTime = Now();
vnTrxCount  = 0;
vnCntr      = 0;
csDestCube  = 'sys.ProcessLog';
csView      = 'TMP_' | GetProcessName;

# determine year, month and day from pStartTime
vsYear  = NumberToString(Year( Date(vnStartTime,1) ));
vsMonth = NumberToString(Month( Date( vnStartTime, 1 ) ));
vsDay   = NumberToString(Day( Date(vnStartTime, 1 ) ));
vsDimYear       = 'sys.Calendar.Year';
vsDimMonth      = 'sys.Calendar.Month';
vsDimDay        = 'sys.Calendar.Day';
vsDimMeasure    = 'sys.Process.ControlMeasure';
vsMeasure       = 'RunCount';
csDim           = 'sys.ArbitraryNumber';

if ( pEntryType = 1 );
# get next available line
    vsMDX = Expand( '{ HEAD( {Filter( {TM1FilterByLevel( {TM1SubsetAll( [%csDim%] ) }, 0 ) }, [%dimYear%].[%vsYear%],[%dimMonth%].[%vsMonth%],[%dimDay%].[%vsDay%],[}Processes].[%pProcess%],[%vsdimMeasure%].[%vsMeasure%] ) = 0 ) } ) };')
    if ( SubsetExists( csDim, csView ) = 1 );
        SubsetDestroy( csDim, csView );
    endif;
    SubsetCreateByMDX( csView, vsMDX, 1 );
    if ( SubsetGetSize( csDim, csView ) = 0 );
        vsNextLine = '1';
    else;
        vsNextLine = SubsetGetElementName( csDim, csView, 1 );
    endif;
else;
    # calculate current line for pStartTime
    vsMeasure = 'User';
    vsMDX = Expand( '{ HEAD( { Filter( { TM1FilterByLevel( { TM1SubsetAll( [%csDim%] ) }, 0 ) }, [%csDestCube%].( [%dimYear%].[%vsYear%], [%vsDimMonth%].[%vsMonth%], [%vsDimDay%].[%vsDay%], [}Processes].[%pProcess%], [%vsDimMeasure%].[%vsMeasure%] ) = "%vsUser%" ) } ) }');
    if ( SubsetExists( csDim, csView ) = 1 );
        SubsetDestroy( csDim, csView );
    endif;
    SubsetCreateByMDX( csView, vsMDX, 1 );
    if ( SubsetGetSize( csDim, csView ) = 0 );
        vsCurLine = '1';
    else;
        vsCurLine = SubsetGetElementName( csDim, csView, 1 );
    endif;
endif;

if ( pEntryType = 0 );
    # error type
    CellPutS( pValue, csDestCube, vsYear, vsMonth, vsDay, pProcess, vsCurLine, 'Message' );
    CellPutN( 1, csDestCube, vsYear, vsMonth, vsDay, pProcess, vsCurLine, 'IsError' );
elseif ( pEntryType = 1 );
    # Start process
    CellPutN( pStartTime, csDestCube, vsYear, vsMonth, vsDay, pProcess, vsNextLine, 'StartTime' );
    CellPutS( pValue, csDestCube, vsYear, vsMonth, vsDay, pProcess, vsNextLine, 'Parameters' );
    CellPutN( 1, csDestCube, vsYear, vsMonth, vsDay, pProcess, vsNextLine, 'RunCount' );
    CellPutS( TM1User(), csDestCube, vsYear, vsMonth, vsDay, pProcess, vsNextLine, 'User' );
elseif ( pEntryType = 2 );
    # End process
    CellPutN( StringToNumber(pValue), csDestCube, vsYear, vsMonth, vsDay, pProcess, vsCurLine, 'EndTime' );
elsif ( pEntryType = 3 );
    # Transaction count
    CellPutN( StringToNumber( pValue ), csDestCube, vsYear, vsMonth, vsDay, pProcess, vsCurLine, 'TrxCount' );
endif;



# =============================================================================
#   EPILOG
# =============================================================================

# Reinstate Cube logging
CubeSetLogChanges( csDestCube, vnCubeLogState );

# =============================================================================
#   END EPILOG
# =============================================================================
