// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract PrizeDistributor {
    address public owner;
    mapping(address => uint) public balances;
    address[] public winners;
    bool public distributed;

    modifier onlyOwner {
        require(msg.sender == owner,"not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function setWinners(address[] calldata _winners) external onlyOwner {
        require(!distributed, "already distributed");
        winners = _winners;
    }

    function distribute() external onlyOwner{
        require(!distributed, "already distributed");
        require(winners.length > 0, "no winners set");

        uint amountPerWinner = address(this).balance / winners.length;

        for (uint i = 0; i < winners.length; i++) {
            address winner = winners[i];
            (bool success, ) = winner.call{value: amountPerWinner}("");
            require(success, "transfer failed");
        }

        distributed = true;
    }

    function withdrawLeftover() external onlyOwner{
        require(distributed, "not distributed yet");
        (bool ok,) = payable(owner).call{value:address(this).balance}("");
        require(ok,"Withdraw fail");
    }


    receive() external payable {}
}