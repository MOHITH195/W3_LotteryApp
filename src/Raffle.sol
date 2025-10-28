// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.19;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
 * @title Raffle
 * @author Mohith
 * @notice This is a simple Raffle for Lottery
 * @dev Used VRF2.5
 */
contract Raffle is VRFConsumerBaseV2Plus {
    /* Errors */
    error Raffle_NotEnoughBal();
    error RaffleTime_NotCompleted();
    error RewardTransfer_Failed();
    error RafleNotOpen_Error();
    error Raffle__UpKeepNotNeeded( uint256 balance , uint256 length, uint256 staate );

    /* Events */
    event EnteredRaffle(address indexed PlayerAddress);
    event WinnerPicked(address indexed PlayerAddress);


    /* Type Declaraaions*/
    enum RafleState {
        OPEN,
        Calculating
        
    }


    /* State Variables */
    uint16 constant NO_OF_CONFIRMATION = 3;
    address payable[] private s_players;
    uint256 private immutable i_entryfee;
    address private s_recent_winner;
    uint256 private immutable i_depTimestamp = block.timestamp;
    uint256 private s_lastTimeStamp; // time of creation
    uint256 private i_interval; // duration
    bytes32 immutable i_keyhash;
    uint256 immutable i_subscription_id;
    uint32 immutable i_callbackGasLimit;
    RafleState private s_Rafle_state;
    uint public test=5;

    /**
     *
     * @param entryfee entry fees for lottery
     * @param interval duration of the lottery
     * @param _vrfCoordinator address of vrfcoordinator
     */
    constructor(
        uint256 entryfee,
        uint256 interval,
        address _vrfCoordinator,
        bytes32 _gaslane,
        uint256 _subscription_id,
        uint32 _callbackGasLimit
    ) VRFConsumerBaseV2Plus(_vrfCoordinator) {
        i_entryfee = entryfee;
        i_interval = interval;
        i_keyhash = _gaslane;
        i_subscription_id = _subscription_id;
        i_callbackGasLimit = _callbackGasLimit;

        s_lastTimeStamp = block.timestamp;
        s_Rafle_state = RafleState.OPEN;
        // s_vrfCoordinator.requestRandomWords();
    }
    function enterRaffle() external payable {
        //  require(msg.sender.balance > i_entryfee , "Balance not sufficient");
        if (msg.sender.balance <= i_entryfee) {
            revert Raffle_NotEnoughBal();
        }
        if(s_Rafle_state != RafleState.OPEN){
            revert RafleNotOpen_Error();
        }

        s_players.push(payable(msg.sender));
        // event enterRaffle();
        emit EnteredRaffle(msg.sender);
    }

    // when should your winner will be picked
    // function checkUpkeep(bytes calldata  /*checkData */)public view returns(bool upkeepNeeded,bytes memory /* PerformData*/)
    function checkUpkeep(bytes memory  /*checkData */)public view returns(bool upkeepNeeded,bytes memory /* PerformData*/)
    {
        bool timeCheck = ((block.timestamp  - s_lastTimeStamp) >=  i_interval);
        bool isOpen =s_Rafle_state == RafleState.OPEN;
        bool hasBalance = address(this).balance >0;
        bool hasPlayers = s_players.length > 0;
        upkeepNeeded = timeCheck && isOpen && hasBalance && hasPlayers;
        return (upkeepNeeded,"");
        

    }


    function performUpkeep(bytes calldata /* performData */ ) external {

        (bool upkeepNeeded , )  = checkUpkeep("");
        if(!upkeepNeeded){
            revert Raffle__UpKeepNotNeeded(address(this).balance , s_players.length , uint256(s_Rafle_state));
        }

        if ((block.timestamp - s_lastTimeStamp) < i_interval) {
            revert RaffleTime_NotCompleted();
        }
        s_Rafle_state = RafleState.Calculating;
        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient.RandomWordsRequest({
            keyHash: i_keyhash,
            subId: i_subscription_id,
            requestConfirmations: NO_OF_CONFIRMATION,
            callbackGasLimit: i_callbackGasLimit,
            numWords: 1,
            extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))

        });

        uint256 requestId = s_vrfCoordinator.requestRandomWords(request);
    }
// CEI : check ,effects ,interaction
    function fulfillRandomWords(uint256 ,/*requestId*/ uint256[] calldata randomWords) internal override {
// checks mean assuming and checking calculations here % operator working

// Effects () Internal COntract State (i simply means how it effects the state or contract)

         uint256 Winner_index  = randomWords[0] % s_players.length;
         address payable winner_Address = s_players[Winner_index];
         s_recent_winner = winner_Address;
         s_players = new address payable[](0);
         s_lastTimeStamp=block.timestamp;


         // interaction (External conttract interaactionss)
         (bool success , ) =winner_Address.call{value:address(this).balance}("");
         if(!success){
            revert RewardTransfer_Failed();
         }
        emit WinnerPicked(s_recent_winner);


    }

    // getters

    function getEntryFee() public view returns (uint256) {
        return i_entryfee;
    }

    function getRaffleState() external view returns (RafleState){
        return s_Rafle_state;
    }

    function getnoOFplayers() public view returns (uint256){
        return s_players.length;
    }

    function getPlayer(uint256 index) public view returns(address){
        return s_players[index];
    }
}
