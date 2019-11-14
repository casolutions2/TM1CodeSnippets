# =============================================================================
#   PROLOG
# =============================================================================

# =============================================================================
#   DESCRIPTION 
#   Purpose:        Set the current system year, month and day
#   Date Created:   2019-11-11
#   Author:         Craig Sawers
# =============================================================================

# =============================================================================
#   CHANGE LOG
# =============================================================================

# =============================================================================
#   VARIABLES and CONSTANTS
# =============================================================================
vnStartTime = Now();
vsStartTime = Date( vnStartTime, 1 );
vsStratTimeOffset = Date( vnStartTime + 15, 1 );
vnTrxCount  = 0;
vnCntr      = 0;


# Get Current Date
vsDAY       = NumberToString( Day( vsStartTime, 1 ) );
vsMONTH     = NumberToString( Month( vsStartTime, 1 ) );
vsCALYEAR   = NumberToString( Year( vsStartTime, 1 ) );

# =============================================================================
# Set Current day
# =============================================================================
vsDim = 'sys.Calendar.DayOfMonth';
vsParent = 'Current Day';
# check parent exists
if ( DimIx( vsDim, vsParent ) = 0 );
    DimensionElementInsertDirect( vsDim, '', vsParent, 'C' );
endif;
vsElement = vsDAY;
# remove any current children
vnCntr = ElCompN( vsDim, vsParent );
while ( vnCntr > 0 );
    vsChild = ElComp( vsDim, vsParent, vnCntr );
    DimensionElementComponentDeleteDirect( vsDim, vsParent, vsChild );
    vnCntr = vnCntr - 1;
end;
# add current value
DimensionElementComponentAddDirect( vsDim, vsParent, vsElement, 1 );

# =============================================================================
# Set current month
# =============================================================================
vsDim       = 'sys.Calendar.Month';
vsParent    = 'Current Month';
# check parent exists
if ( DimIx( vsDim, vsParent ) = 0 );
    DimensionElementInsertDirect( vsDim, '', vsParent, 'C' );
endif;
vsElement = vsMONTH;
# remove any current children
vnCntr = ElCompN( vsDim, vsParent );
while ( vnCntr > 0 );
    vsChild = ElComp( vsDim, vsParent, vnCntr );
    DimensionElementComponentDeleteDirect( vsDim, vsParent, vsChild );
    vnCntr = vnCntr - 1;
end;
# add current value
DimensionElementComponentAddDirect( vsDim, vsParent, vsElement, 1 );

# =============================================================================
# set current year
# =============================================================================
vsDim       = 'sys.Calendar.Year';
vsParent    = 'Current Year';
# check parent exists
if ( DimIx( vsDim, vsParent ) = 0 );
    DimensionElementInsertDirect( vsDim, '', vsParent, 'C' );
endif;
vsElement = vsCALYEAR;
# remove any current children
vnCntr = ElCompN( vsDim, vsParent );
while ( vnCntr > 0 );
    vsChild = ElComp( vsDim, vsParent, vnCntr );
    DimensionElementComponentDeleteDirect( vsDim, vsParent, vsChild );
    vnCntr = vnCntr - 1;
end;
# add current value
DimensionElementComponentAddDirect( vsDim, vsParent, vsElement, 1 );

# =============================================================================
# set Financial year and period
# based on a July to June financial year
# =============================================================================
if ( Month( vnStartTimeOffset ) > 6 );
    vsFinYear = NumberToString( Year( vsStartTimeOffset ) + 1 );
    vsFinPd     = NumberToString( Month( vsStartTimeOffset ) - 6 );
else;
    vsFinYear   = vsCALYEAR;
    vsFinPd     = NumberToString( Month( vsStartTimeOffset ) + 6 );
endif;

vsDim       = 'gbl.Year';
vsParent    = 'Current Financial Year';
# check parent exists
if ( DimIx( vsDim, vsParent ) = 0 );
    DimensionElementInsertDirect( vsDim, '', vsParent, 'C' );
endif;
vsElement = vsFinYear;
# remove any current children
vnCntr = ElCompN( vsDim, vsParent );
while ( vnCntr > 0 );
    vsChild = ElComp( vsDim, vsParent, vnCntr );
    DimensionElementComponentDeleteDirect( vsDim, vsParent, vsChild );
    vnCntr = vnCntr - 1;
end;
# add current value
DimensionElementComponentAddDirect( vsDim, vsParent, vsElement, 1 );

# financial period
vsDim       = 'gbl.Month';
vsParent    = 'Current Month';
# check parent exists
if ( DimIx( vsDim, vsParent ) = 0 );
    DimensionElementInsertDirect( vsDim, '', vsParent, 'C' );
endif;
vsElement = vsMONTH;
# remove any current children
vnCntr = ElCompN( vsDim, vsParent );
while ( vnCntr > 0 );
    vsChild = ElComp( vsDim, vsParent, vnCntr );
    DimensionElementComponentDeleteDirect( vsDim, vsParent, vsChild );
    vnCntr = vnCntr - 1;
end;
# add current value
DimensionElementComponentAddDirect( vsDim, vsParent, vsElement, 1 );


