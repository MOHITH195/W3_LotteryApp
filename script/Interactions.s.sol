

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

import {Script,console2} from "forge-std/Script.sol";
import {HelperConfig , ChainOnstants} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "./Mock/LinkToken.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";


contract CreateSubsription is Script{

    function createSubconfig() public returns(uint256 , address){
        HelperConfig helperconfig = new HelperConfig();
        address vrfCorrdinator = helperconfig.getconfig()._vrfCoordinator;
        (uint256 subid,)= createSub(vrfCorrdinator);
        
        return (subid,vrfCorrdinator);
     
    }
    function createSub(address _vrfCoordinator) public returns( uint256,address){
        console2.log("Creating Subscription .. ChainID : ",block.chainid);
        vm.startBroadcast();
        uint256 subid = VRFCoordinatorV2_5Mock(_vrfCoordinator).createSubscription();
        vm.stopBroadcast();
        console2.log("Sub id created : ",subid);
        console2.log("update the subid in helperconfig");
        return ( subid,_vrfCoordinator);
    }

    function run() public {
        
        createSubconfig();
    }
}

contract FundSubscription is Script{
    uint256 public constant Fund_amount = 3 ether;


    function fundSubConfig() public {
        HelperConfig helperconfig = new HelperConfig();
        address vrfCoordinator = helperconfig.getconfig()._vrfCoordinator;
        uint256 subid = helperconfig.getconfig()._subscription_id;
        address linkToken = helperconfig.getconfig().link;
        fundsub(vrfCoordinator,subid,linkToken);
    }
    function fundsub(address _vrfCoordinator , uint256 _subid , address _link) public {
        console2.log("Funding Subscription subscription id :",_subid);
        console2.log("Using VRF coordinator :",_vrfCoordinator);
        ChainOnstants cons = new ChainOnstants();
        if(block.chainid == cons.LOCAL_CHAIN_ID()){
            vm.startBroadcast();
            VRFCoordinatorV2_5Mock(_vrfCoordinator).fundSubscription(_subid,Fund_amount);
            vm.stopBroadcast();

        }else{
            vm.startBroadcast();
            LinkToken(_link).transferAndCall( /* later */
                _vrfCoordinator,
                Fund_amount,
                abi.encode(_subid)
            );
            vm.stopBroadcast();

        }
        


        
    }
    function run() public {
        fundSubConfig();
    }
}

contract AddConsumer is Script{
    
    function addconsumerConfig(address consumer) public {
        HelperConfig helperconfig = new HelperConfig();
        uint256 subid = helperconfig.getconfig()._subscription_id;
        address vrfCoordinator = helperconfig.getconfig()._vrfCoordinator;
        AddConsumers(subid,vrfCoordinator,consumer);
    }
    function AddConsumers(uint256 _subid,address _vrfcoordinator,address consumer) public {
        // address consumer;
        console2.log("Adding Consumer to subscription id : ",_subid);
        console2.log("Using VRF coordinator : ",_vrfcoordinator);
        console2.log("on ChainID : ",block.chainid);
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock(_vrfcoordinator).addConsumer(_subid, consumer);
        vm.stopBroadcast();
    }
    
    
    function run() public {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("Raffle",block.chainid);
        addconsumerConfig(mostRecentlyDeployed);
    }
}
