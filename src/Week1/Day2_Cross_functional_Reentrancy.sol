// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Staking{
  mapping(address => uint) public stakes;


  function stake() external payable{
    stakes[msg.sender] += msg.value;
  }
 

  function withdraw() external{
    uint amount = stakes[msg.sender];
    require(amount >0,"ETH transfer failed");

    (bool success,) = msg.sender.call{value:amount}("");
    require(success);
    stakes[msg.sender] = 0;
  }

  function claimRewards() external {
    uint reward = stakes[msg.sender] / 10;
    require(reward > 0 ,"No reward");

    (bool success,) =  payable(msg.sender).call{value:reward}("");
    require(success,"Reward transfer failed");
  }

  receive() external payable {}
}