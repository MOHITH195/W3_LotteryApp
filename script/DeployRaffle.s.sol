// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubsription , FundSubscription , AddConsumer} from "./Interactions.s.sol";
// import {} from "for"

contract DeployRaffle is Script{
    function run()  public {  
        
    }

    function deployContract() public returns (Raffle,HelperConfig){
        HelperConfig helperconfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperconfig.getconfig();

        if(config._subscription_id == 0){
            CreateSubsription createsubscription = new CreateSubsription();
            uint256 subid;
            address vrfcoordinator;
            (subid,vrfcoordinator) = createsubscription.createSub(config._vrfCoordinator);
            config._subscription_id = subid;
            config._vrfCoordinator = vrfcoordinator;
            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundsub(
                config._vrfCoordinator,
                config._subscription_id,
                config.link
            );
  
        }

        vm.startBroadcast();
        Raffle raffle = new Raffle(
            config.entryfee,
            config.interval,
            config._vrfCoordinator,
            config._gaslane,
            config._subscription_id,
            config._callbackGasLimit
        );
        vm.stopBroadcast();

            AddConsumer addConsumer = new AddConsumer();
            addConsumer.AddConsumers(
                config._subscription_id,
                config._vrfCoordinator,
                address(raffle)
            );

        return (raffle,helperconfig);
        
    }
    
}