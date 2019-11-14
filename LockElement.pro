# =============================================================================
#   PROLOG
# =============================================================================

#Params = 'pLock; pDim; pEle;
# Allow input to locked items
CubeLockOverride(1);

csCube = Expand( '}ElementProperties_%pDim%' );
# Check if Properties cube exists. If not create it
if ( CubeExists( vsCube ) =0);
    CubeCreate( vsCube , pDim , vsEleProp );
Endif;
vsClient = TM1User();
# Determine if a lock is required
if ( pLock @= '1' );
    vsValue = vsClient;
elseif ( pLock @= '0' );
    vsValue = '';
endif;
CellPutS( vsValue, vsCube, pEle, 'LOCK' );

# =============================================================================
#   END PROLOG
# =============================================================================
