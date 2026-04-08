// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract ERC20 {
    string public constant name = "DONAT";
    string public constant symbol = "DON";
    uint8 public constant decimals = 18;


    uint public totalSupply;

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    // transfer function
    function _transfer(address from,address to,uint256 value) public{
        require(balanceOf[from] >= value,"INSUFFICIENT TOKEN");
        require(to != address(0), "INVALID_ADDRESS");
        balanceOf[from] -= value;
        balanceOf[to] += value;
        emit Transfer(from, to, value);
    }
    function transfer(address to,uint256 value) external returns(bool){
        _transfer(msg.sender,to,value);
        return true;
    }
    // mint function
    function _mint(address to,uint256 value) internal {
        require(to != address(0), "INVALID_ADDRESS");
        totalSupply += value;
        balanceOf[to] += value;
        emit Transfer(address(0), to, value);
    }

    function mint(address to, uint256 value) external {
    _mint(to, value);
    }

    // burn function
    function _burn(address from,uint256 value) internal {
        totalSupply -= value;
        balanceOf[from] -= value;
        emit Transfer(from, address(0), value);
    }
    function burn(address from,uint256 value) external {
        _burn(from, value);
    }

    // approve function 
    function _approve(address owner, address spender, uint value) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }
    function approve(address spender, uint value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    //transferFrom function
    function transferFrom(address from, address to, uint value) external returns (bool) {
        allowance[from][msg.sender] -=value;
        _transfer(from, to, value);
        return true;
    }

}
