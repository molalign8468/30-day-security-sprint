// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./interfaces/IERC20.sol";
import "./libraries/Math.sol";
import "./ERC20.sol";

contract Pair is ERC20 {
    address public token0;
    address public token1;

    uint112 private reserve0;
    uint112 private reserve1;

    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));
    uint public constant MINIMUM_LIQUIDITY = 1000;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    

    constructor(address _token0,address _token1){
        token0 = _token0;
        token1 = _token1;
    }
    function _safeTransfer(address token,address to,uint256 value) private{
        (bool ok, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(ok && (data.length == 0 || abi.decode(data,(bool))), "TRANSFER_FAILED");

    }

    function _update(uint _balance0,uint _balance1) private {
        reserve0 = uint112(_balance0);
        reserve1 = uint112(_balance1);
    }

    function getReserves() public view returns(uint112 _reserve0,uint112 _reserve1) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
    }

    function mint(address to) external returns(uint liquidity) {
        // get balance of after get the liquidity pair 
        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));

        // get amount of pairs in reserve which is send to the pool
        uint amount0 = balance0 - reserve0;
        uint amount1 = balance1 - reserve1;

        // calculate liquidity
        uint _totalSupply = totalSupply;
        if(_totalSupply == 0){
            uint256 initialLiquidity = Math.sqrt(amount0 * amount1);
            require(initialLiquidity > MINIMUM_LIQUIDITY, 'INSUFFICIENT_INITIAL_LIQUIDITY');
            liquidity = initialLiquidity-MINIMUM_LIQUIDITY;
            _mint(address(1), MINIMUM_LIQUIDITY);
        }else{
            liquidity = Math.min(amount0 * _totalSupply / reserve0, amount1 * _totalSupply / reserve1);
        }
        
        require(liquidity > 0, 'INSUFFICIENT_LIQUIDITY_MINTED');

        //Mint LP token
        _mint(to, liquidity);

        // update reserve
        _update(balance0, balance1);
        emit Mint(msg.sender, amount0, amount1);
    }

    function burn(address to) external returns(uint amount0,uint amount1){
        // get liquidity share token amount
        uint liquidity  = balanceOf[address(this)];
        // get each token amount
        address _token0  = token0;
        address _token1 = token1;
        uint balance0 = IERC20(_token0).balanceOf(address(this));
        uint balance1 = IERC20(_token1).balanceOf(address(this));
        uint _totalSupply = totalSupply;
        amount0 = liquidity * balance0 / _totalSupply;
        amount1 = liquidity * balance1 / _totalSupply;
        // burn
        require(amount0 > 0 && amount1 > 0,"INSUFFICIENT_LIQUIDITY_BURNED");
        _burn(address(this),liquidity);
        _safeTransfer(token0,to,amount0);
        _safeTransfer(token1,to,amount1);
        // update reserve
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));
        _update(balance0,balance1);
        emit Burn(msg.sender, amount0, amount1, to);
        
    }
    function swap(uint amount0Out, uint amount1Out, address to) external {
        require(amount0Out > 0 || amount1Out > 0, "INSUFFICIENT_OUTPUT");

        (uint112 _reserve0, uint112 _reserve1) = getReserves();

        require(amount0Out < _reserve0 && amount1Out < _reserve1, "INSUFFICIENT_LIQUIDITY");

        // send tokens out
        if (amount0Out > 0) _safeTransfer(token0, to, amount0Out);
        if (amount1Out > 0) _safeTransfer(token1, to, amount1Out);

        // get new balances
        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));

        // calculate amount in
        uint amount0In = balance0 > (_reserve0 - amount0Out)
            ? balance0 - (_reserve0 - amount0Out)
            : 0;

        uint amount1In = balance1 > (_reserve1 - amount1Out)
            ? balance1 - (_reserve1 - amount1Out)
            : 0;

        require(amount0In > 0 || amount1In > 0, "INSUFFICIENT_INPUT");

        _update(balance0, balance1);
}
}
