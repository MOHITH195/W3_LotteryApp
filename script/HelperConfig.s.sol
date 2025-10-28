// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
abstract contract ChainOnstants {
    /* VRF MOCK VALUES */
    uint96 public MOCK_BASE_FEE = 0.25 ether;
    uint96 public MOCK_GAS_PRICE_LINK = 1e9;
    // LINK / ETH price 
    int256 public MOCK_GAS_PER_UNIT_LINK = 4e15;

    uint256 public constant sepolia = 11155111;
    uint256 public constant LOCAL_CHAIN_ID =31337;
    
    
}
contract HelperConfig is Script,ChainOnstants {

    error HelperConfig__InvalidChainid();


    struct NetworkConfig {
        uint256 entryfee;
        uint256 interval;
        address _vrfCoordinator;
        bytes32 _gaslane;
        uint256 _subscription_id;
        uint32 _callbackGasLimit;
    }

    NetworkConfig public localNetworkConfig;
    mapping(uint256 chainid => NetworkConfig ) public networkconfig;
        NetworkConfig public activeNetworkConfig;


    constructor() {
        networkconfig[sepolia] = getSepoliaEth();
    }

    function getconfig() external  returns(NetworkConfig memory){
        return getconfigByCHainID(block.chainid);
        // return activeNetworkConfig;
    }

    function getconfigByCHainID(uint256 chainid) public returns(NetworkConfig memory){

        if(networkconfig[chainid]._vrfCoordinator != address(0)){
            return networkconfig[chainid];
        }else if(chainid==LOCAL_CHAIN_ID){
            return getorCreateAnvilconfig();
        }else{
            revert HelperConfig__InvalidChainid();
        }
    }

    function getSepoliaEth() public pure returns(NetworkConfig memory) {
        
        return NetworkConfig({
        entryfee: 0.001 ether,
        interval: 30,
        _vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
        _gaslane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
        _subscription_id: 0,
        _callbackGasLimit: 500000
         });
    }

    function getorCreateAnvilconfig() public returns (NetworkConfig memory temp){
        if(localNetworkConfig._vrfCoordinator != address(0)){
            return localNetworkConfig;
        }

        // deploy mock and such
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfMock = new VRFCoordinatorV2_5Mock(
            MOCK_BASE_FEE,
            MOCK_GAS_PRICE_LINK,
            MOCK_GAS_PER_UNIT_LINK
        );
        vm.stopBroadcast();
        
        localNetworkConfig = NetworkConfig({
        entryfee: 0.001 ether,
        interval: 30,
        _vrfCoordinator: address(vrfMock),
        _gaslane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
        _subscription_id: 0, // might have to fix
        _callbackGasLimit: 500000
        });

        return localNetworkConfig;
        
        
        
    }
    
}