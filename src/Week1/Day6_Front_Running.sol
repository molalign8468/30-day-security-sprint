// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract CarMarket {
    uint256 public reserveBalance = 100 ether; 
    uint256 public carSupply = 100;           
    mapping(address => uint256) public carOwner;

    function getPrice() public view returns (uint256) {
        return reserveBalance / carSupply; 
    }

    function buyCar() external payable {
        uint256 price = getPrice();
        require(msg.value >= price, "Not enough ETH");
        
        reserveBalance += price; 
        carSupply -= 1;          
        _transfer(msg.sender, 1);
    }

    function sellCar() external {
        uint256 price = getPrice();
        _transfer(address(this), 1);
        reserveBalance -= price; 
        carSupply += 1;          
        (bool ok,) = payable(msg.sender).call{value:price}("");
        require(ok);
    }

    function _transfer(address _owner,uint _amount) private {
        carOwner[_owner] += _amount;
    }
}