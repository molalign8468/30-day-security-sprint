// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Treasury{
    address public owner;
    constructor(address _owner){
        owner = _owner;
    }

    modifier onlyOwner(){
        require(tx.origin == owner,"Only Owner");
        _;
    }
    function changeOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }
    function deposit() external payable {}

    function withdraw() external onlyOwner {
        require(address(this).balance > 0 ,"Low balance");
        (bool ok,)  = payable(msg.sender).call{value:address(this).balance}("");
        require(ok,"Transaction fail");
    }

    function kill(address _to) external onlyOwner{
        selfdestruct(payable(_to));
    }
}