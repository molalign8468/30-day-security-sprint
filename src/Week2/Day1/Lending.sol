// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IERC20 {
    function transferFrom(address from, address to, uint amount) external returns (bool);
    function transfer(address to, uint amount) external returns (bool);
}

interface IPair {
    function getReserves() external view returns (uint112, uint112);
    function token0() external view returns (address);
    function token1() external view returns (address);
}

contract Lending {
    IERC20 public collateralToken;
    IERC20 public borrowToken;
    IPair public pair;

    mapping(address => uint) public collateral;
    mapping(address => uint) public debt;


    constructor(address _collateral, address _borrowToken,address _pair){
        collateralToken  = IERC20(_collateral);
        borrowToken  = IERC20(_borrowToken);
        pair = IPair(_pair);
    }
    function deposit(uint amount) external {
        collateralToken.transferFrom(msg.sender, address(this), amount);
        collateral[msg.sender] += amount;
    }
    function getPrice() public view returns (uint price) {
        (uint112 r0, uint112 r1) = pair.getReserves();

        if (pair.token0() == address(collateralToken)) {
            price = uint(r1) * 1e18 / uint(r0);
        } else {
            price = uint(r0) * 1e18 / uint(r1);
        }
    }
    function borrow(uint amount) external {
        uint price = getPrice();
        uint collateralValue = collateral[msg.sender] * price / 1e18;

        require(collateralValue >= amount * 2, "Not enough collateral");

        debt[msg.sender] += amount;
        borrowToken.transfer(msg.sender, amount);
    }
}