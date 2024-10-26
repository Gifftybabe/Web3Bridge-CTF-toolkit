// script/Deploy.s.sol
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {ChallengeTwo} from "../src/ChallengeTwo.sol";
import {Attack} from "../test/ChallengeTwo.t.sol";

contract DeployScript is Script {
    ChallengeTwo public challenge;
    Attack public attack;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Connect to existing challenge contract
        challenge = ChallengeTwo(0x8D6B11D53A4CE78658d8335EafAa1e77A2FB101d);
        
        // Step 1: Pass the key (we found it's 2524)
        challenge.passKey(2524);
        
        // Step 2: Deploy attack contract and execute attack
        attack = new Attack(address(challenge), "Gifftybabe");
        
        // Execute the attack
        (bool success,) = address(attack).call(
            abi.encodeWithSignature("initiateAttack()")
        );
        require(success, "Attack failed");
        
        // Step 3: Add name to champions
        challenge.addYourName();

        vm.stopBroadcast();
    }
}