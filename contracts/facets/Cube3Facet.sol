pragma solidity 0.8.19;

import {DiamondStorageLib} from "../lib/DiamondStorageLib.sol";

interface IRouter {

    struct FunctionProtectionStatusUpdate {
        bytes4 fnSelector;
        bool protectionEnabled;
    }

    function initiateIntegrationRegistration(address _integrationAdmin) external returns (bool);
    function finalizeIntegrationRegistration(
        address _integration,
        bytes calldata _registrationSignature,
        FunctionProtectionStatusUpdate[] calldata _fnProtectionData
    ) external;
}

interface ISmartLoanDiamondBeacon {
    function getFacet(bytes4 sig) external view returns (address);
}



contract Cube3Facet {

    uint256 private constant CUBE3_PAYLOAD_LENGTH = 320;

    // setting the router as a constant reduces an SLOAD, but could also be set in the initializer
    address private constant CUBE3_ROUTER = 0x32EEce76C2C2e8758584A83Ee2F522D4788feA0f;

    address private constant DIAMONED_BEACON = 0x2916B3bf7C35bd21e63D01C93C62FB0d4994e56D;

    event Cube3FacetInitialized();

    function initialize() external  {      
        emit Cube3FacetInitialized();
    }

    function preRegister() external {
        bool preRegistered = IRouter(CUBE3_ROUTER).initiateIntegrationRegistration(msg.sender); 
        require(preRegistered, "pre-registration failed");
    }

    function register(
        bytes calldata registrationSignature,
        
        IRouter.FunctionProtectionStatusUpdate[] calldata fnProtectionData
    ) external {
        IRouter(CUBE3_ROUTER).finalizeIntegrationRegistration(address(this), registrationSignature, fnProtectionData);
    }

    /// @dev the SmartLoanDiamondBeaconProxy delegatecalls this facet, which routes the tx to the router, if it succeeds, it makes the original call
    /// @dev User EOA is `msg.sender`
    /// @dev addtress(this) is the smart loan account proxy
    fallback() external payable {
        address facet = ISmartLoanDiamondBeacon(DIAMONED_BEACON).getFacet(msg.sig);
        require(facet != address(0), "Diamond: Function does not exist");

        bytes memory routerCalldata = abi.encodeWithSignature(
            "routeToModule(address,uint256,uint256,bytes)", msg.sender, msg.value, CUBE3_PAYLOAD_LENGTH, msg.data
        );

        // First, we route the transaction (including the payload data) through the CUBE3 protocol. IF the transaction is deemed safe,
        // ie it succeeds, then we execute the original function call using the facet by removing the payload data
        assembly {
            // Load the size of the routerCalldata (first 32 bytes)
            let routerDataSize := mload(routerCalldata)

            let cubeResult :=
                call(
                    gas(),
                    CUBE3_ROUTER,
                    0,
                    add(routerCalldata, 32), // pointer to the start of input data, after length prefix,
                    routerDataSize,
                    0,
                    0
                )

            // we revert if it reverts, and do nothing on success so that the tx can sent to the original facet
            switch cubeResult
            case 0 { revert(0, returndatasize()) }

            // get the original function calldata by slicing off the CUBE3 payload (320 bytes)
            let adjustedSize := sub(calldatasize(), 320)

            // copy function selector and any arguments
            calldatacopy(0, 0, adjustedSize)

            // execute function call using the facet
            let primeResult := delegatecall(gas(), facet, 0, adjustedSize, 0, 0)

            // get any return value
            returndatacopy(0, 0, returndatasize())
            // return any return value or error back to the fallback
            switch primeResult
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    receive() external payable {
        revert("no eth accepted");
    }
}
