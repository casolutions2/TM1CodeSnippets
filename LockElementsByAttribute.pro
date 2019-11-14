# =============================================================================
#   PROLOG
# =============================================================================

# process description 
# lock dimension elements based on an attribute

# =============================================================================
#   PARAMETERS
#   pDimension      - dimension to lock elements in
#   pAttribute      - attribute within the dimension that is to be used to determine lock status
#   pAttributeValue - value of the attribute that is to be used to determine lock status
#   pLock           - 1 = Lock, 0 = Unlock
# =============================================================================

# check
if ( DimensionExists( pDimension ) = 0 );
    ItemReject( Expand('Dimension specified (%pDimension%) does not exist!') );
    ProcessError;
endif;

csDestCube = Expand( '}ElementProperties_%pDimension%');
csAttrCube = Expand( '}ElementAttributes_%pDimension%');

if ( DimIx( pDimension, pAttribute ) = 0 );
    ItemReject( Expand( 'Attribute specified (%pAttribute%) does not exist!') );
    ProcessError;
endif;
if ( pAttributeValue @= '' );
    ItemReject( 'Attribute value cannot be blank!' );
    ProcessError;
endif;

csSubName = '4' | GetProcessName();
vnCountRecords = 0;

# leave logging on?
vnCubeLogState = CubeGetLogChanges( csDestCube );
CubeSetLogChanges( csDestCube, 0 );

# Allow input to locked items
CubeLockOverride(1);

vsMDX = Expand('{ TM1SubsetAll( [%pDimension%] ) }');
SubsetCreateByMDX( csSubName, vsMDX, 1 );
vnLoop = SubsetGetSize( pDimension, csSubName );

#unlock all elements first
while ( vnCountRecords <= vnLoop );
    vnCountRecords = vnCountRecords + 1;
    vsElement = SubsetGetElementName( pDimension, csSubName, vnCountRecords );
    CellPutS( '', csDestCube, vsElement, 'Lock' );
end;
SubsetDestroy( pDimension, csSubName ); 

# set element lock according to attribute
vnCountRecords = 0;
vsMDX = Expand( '{ Filter( { TM1SubsetAll( [%pDimension%] ) }, [%pDimension%].[%pAttribute%]=''%pAttributeValue%'' ) }');
LogOutput( 'DEBUG', Expand( 'Locking MDX subset is %vsMDX%' ) );
SubsetCreateByMDX( csSubName, vsMDX );
vnLoop = SubsetGetSize( pDimension, csSubName );

# set lock
while ( vnCountRecords <= vnLoop );
    vnCountRecords = vnCountRecords + 1;
    vsElement = SubsetGetElementName( pDimension, csSubName, vnCountRecords );
    CellPutS( 'ADMIN', csDestCube, vsElement, 'LOCK' );
end;
SubsetDestroy( pDimension,  csSubName );

# =============================================================================
#   END PROLOG
# =============================================================================

# =============================================================================
#   EPILOG
# =============================================================================

# Reinstate Cube logging
CubeSetLogChanges( csDestCube, vnCubeLogState );

# Log end and trx count
ExecuteProcess( 'Sys.Log.Process', 'pEntryType', 3, 'pProcess', GetProcessName(), 'pStartTime', vnStartTime, 'pValue', NumberToString( vnTrxCount) );
ExecuteProcess( 'Sys.Log.Process', 'pEntryType', 2, 'pProcess', GetProcessName(), 'pStartTime', vnStartTime, 'pValue', NumberToString( Now() ) );

# log if error file produced
if ( Long(GetProcessErrorFilename) > 0 );
    ExecuteProcess( 'sys.Log.Process', 'pEntryType', 0, 'pProcess', GetProcessName(), 'pStartTime', vnStartTime, 'pValue', GetProcessErrorFilename );
endif;

# =============================================================================
#   END EPILOG
# =============================================================================
