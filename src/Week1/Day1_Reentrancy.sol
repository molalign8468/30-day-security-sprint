// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract VulnerableVault {
    mapping(address => uint) public balances;
    
    function deposit() external payable{
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint amount = balances[msg.sender];
        require(amount > 0,"Insufficient Balance");
        (bool success,) = payable(msg.sender).call{value:amount}("");
        require(success);
        balances[msg.sender]=0;
    }
}
