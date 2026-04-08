// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IERC20 {
    function transfer(address to, uint amount) external returns (bool);
    function transferFrom(address from, address to, uint amount) external returns (bool);
    function balanceOf(address user) external view returns (uint);
}

interface IFlashLoanReceiver {
    function execute() external;
}

contract FlashLoan{
    IERC20 public  token;

    constructor (address _token) {
        token = IERC20(_token);
    }

    function flashLoan(uint amount,address receiver) external {
        uint balanceBefore = token.balanceOf(address(this));
        require(balanceBefore >= amount, "Not enough liquidity");

        token.transfer(receiver, amount);
        IFlashLoanReceiver(receiver).execute();

        uint balanceAfter = token.balanceOf(address(this));
        require(balanceAfter >= balanceBefore, "Flash loan not repaid");
       
    }
}