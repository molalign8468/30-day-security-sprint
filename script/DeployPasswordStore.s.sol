// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Week2/Day5_Password_Store.sol";

contract DeployPasswordStore is Script {
    function run() public returns (PasswordStore passwordStore) {
        vm.startBroadcast();
        passwordStore = new PasswordStore();
        passwordStore.setPassword("myPassword");
        vm.stopBroadcast();
    }
}
