// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {console} from "forge-std/Console.sol";



// Simplified 2016-era Solidity
contract KingOfTheEtherThrone {
    address public king;
    uint public claimPrice = 1 ether;

    function claimThrone() external payable {
        require(msg.value > claimPrice);


        uint compensation = (msg.value * 9) / 10;
        (bool ok,) = payable(king).call{value:compensation}("");

        king = msg.sender;
        claimPrice = (claimPrice * 3) / 2;
    }
}