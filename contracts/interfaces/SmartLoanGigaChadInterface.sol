// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.17;

import "./facets/avalanche/IYieldYakFacet.sol";
import "./facets/avalanche/IYieldYakSwapFacet.sol";
import "./facets/avalanche/IPangolinDEXFacet.sol";
import "./facets/avalanche/ITraderJoeDEXFacet.sol";
import "./facets/IUniswapV2DEXFacet.sol";
import "./facets/IAssetsOperationsFacet.sol";
import "./facets/IOwnershipFacet.sol";
import "./facets/ISmartLoanViewFacet.sol";
import "./facets/ISmartLoanLiquidationFacet.sol";
import "./facets/ISmartLoanWrappedNativeTokenFacet.sol";
import "./facets/ISolvencyFacetProd.sol";
import "./IDiamondLoupe.sol";
import "./facets/celo/IUbeswapDEXFacet.sol";
import "./facets/avalanche/IVectorFinanceFacet.sol";
import "./facets/avalanche/IBeefyFinanceFacet.sol";

interface SmartLoanGigaChadInterface is IYieldYakSwapFacet, IDiamondLoupe, IBeefyFinanceFacet, ISmartLoanWrappedNativeTokenFacet, IPangolinDEXFacet, IUniswapV2DEXFacet, IAssetsOperationsFacet, IOwnershipFacet, ISmartLoanLiquidationFacet, ISmartLoanViewFacet, ISolvencyFacetProd, IYieldYakFacet, IVectorFinanceFacet, IUbeswapDEXFacet, ITraderJoeDEXFacet {

}
