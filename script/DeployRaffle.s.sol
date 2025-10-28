// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
// import {} from "for"

contract DeployRaffle is Script{
    function run()  public {  
        
    }

    function deployContract() public returns (Raffle,HelperConfig){
        HelperConfig helperconfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperconfig.getconfig();

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

        return (raffle,helperconfig);
        
    }
    
}