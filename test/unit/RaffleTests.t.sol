// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

import {console} from "forge-std/console.sol";
import {Test} from "forge-std/Test.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Raffle} from "src/Raffle.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract RaffleUnitTest is Test {
    Raffle public raffle;
    HelperConfig public helperconfig;
    address public player = makeAddr("player");
    address public player1 = makeAddr("player1");
    uint256 public STARTER_BALENCE = 10 ether;

    event EnteredRaffle(address indexed PlayerAddress);
    event WinnerPicked(address indexed PlayerAddress);

    
        uint256 entryfee;
        uint256 interval;
        address _vrfCoordinator;
        bytes32 _gaslane;
        uint256 _subscription_id;
        uint32 _callbackGasLimit;


    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle,helperconfig) = deployer.deployContract();
        HelperConfig.NetworkConfig memory config = helperconfig.getconfig();
        entryfee = config.entryfee;
        interval=config.interval;
        _vrfCoordinator=config._vrfCoordinator;
        _gaslane=config._gaslane;
        _subscription_id=config._subscription_id;
        _callbackGasLimit=config._callbackGasLimit;
        vm.deal(player, STARTER_BALENCE);
        vm.deal(player1, STARTER_BALENCE);

    }

    function testRafleInitialState() view public   {
        assert(raffle.getRaffleState() == Raffle.RafleState.OPEN);
    }

    function testEntranceRaaffle() public {
            vm.deal(player, 10 ether);

        console.log(raffle.getnoOFplayers());
        console.log(entryfee);
        vm.startPrank(player) ;// arrange
        // vm.expectRevert();
        raffle.enterRaffle{value:entryfee}(); // act
        console.log(raffle.getnoOFplayers());
        vm.stopPrank();

    }

    function testRafleRecordPlayerAfterEntrance() public {
        vm.startPrank(player);
        raffle.enterRaffle{value:entryfee}();
        console.log(raffle.getPlayer(0));
        vm.stopPrank();
        vm.startPrank(player1);
        raffle.enterRaffle{value:entryfee}();
        console.log(raffle.getPlayer(1));
        vm.stopPrank();

        assert(raffle.getPlayer(0)==player && raffle.getPlayer(1)==player1);
    }

    function testEnteringRaffleEmitsEvent() public {
        vm.startPrank(player);
        vm.expectEmit(true, false, false, false , address(raffle)); // 4th one is for who is emmiting the event
        emit EnteredRaffle(player);
        raffle.enterRaffle{value:entryfee}();
    
    }

    function testDonotAllowPlayersWhileRaffleIsCalculating() public {
        vm.prank(player);
        raffle.enterRaffle{value:entryfee}();
        vm.warp(block.timestamp + 1 + interval); // it is useed to manipulate the local block chaain time
        vm.roll(block.number + 1); // it is used to manipulate the local block chain block number
        raffle.performUpkeep("");

        // Act and Assert

        vm.expectRevert();
        vm.prank(player);
        raffle.enterRaffle{value:entryfee}();


    }

    function testCheckUPKeepReturnsFalse() public {
        // vm.prank(player);
        // raffle.enterRaffle{value:entryfee}();
        // Arrange
        vm.warp(block.timestamp + 1 + interval); // it is useed to manipulate the local block chaain time
        vm.roll(block.number + 1); // it is used to manipulate the local block chain block number

    //act
        (bool upkeep , ) = raffle.checkUpkeep("");
    //assert
        assert(!upkeep);
    }

function testCheckUPKeepReturnsFalseIfRaffleIsNotOpen() public {
        vm.prank(player);
        raffle.enterRaffle{value:entryfee}();
        vm.warp(block.timestamp + 1 + interval); // it is useed to manipulate the local block chaain time
        vm.roll(block.number + 1); // it is used to manipulate the local block chain block number
        raffle.performUpkeep("");

        //act
        (bool upkeep , ) = raffle.checkUpkeep("");
    //assert
        assert(!upkeep);
}



}