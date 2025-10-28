

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";


contract CreateSubsription is Script{
    function createSub() public{
        HelperConfig helperconfig = new HelperConfig();
        address vrfCorrdinator = helperconfig.getconfig()._vrfCoordinator;
        

    }

    function run() public {
        createSub();
    }
}
