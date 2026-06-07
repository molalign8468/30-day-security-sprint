// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract PuzzleWallet {
    address public owner;      // slot 0
    uint256 public maxBalance; // slot 1

    mapping(address => bool) public whitelisted;
    mapping(address => uint256) public balances;

    function init(uint256 _maxBalance) external {
        require(owner == address(0));

        owner = msg.sender;
        maxBalance = _maxBalance;
    }


    modifier onlyWhitelisted() {
        require(whitelisted[msg.sender], "not whitelisted");
        _;
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    function addToWhitelist(address user) external onlyOwner {
        whitelisted[user] = true;
    }
    function deposit() external payable onlyWhitelisted {
        balances[msg.sender] += msg.value;
    }

    function multicall(bytes[] calldata data) external payable onlyWhitelisted {
        bool depositCalled;

        for (uint256 i; i < data.length; i++) {

            bytes4 selector;

            assembly {
                selector := calldataload(
                    add(data.offset, mul(i, 0x20))
                )
            }

            if (selector == this.deposit.selector) {
                require(
                    !depositCalled,
                    "deposit once"
                );

                depositCalled = true;
            }

            (bool ok,) =
                address(this).delegatecall(
                    data[i]
                );

            require(ok);
        }
    }

    function execute( address to, uint256 value, bytes calldata data) external onlyWhitelisted {
        require(
            balances[msg.sender] >= value
        );

        balances[msg.sender] -= value;

        (bool ok,) = to.call{value:value}(data);

        require(ok);
    }


    function setMaxBalance( uint256 _maxBalance ) external onlyWhitelisted {
        require(
            address(this).balance == 0
        );

        maxBalance = _maxBalance;
    }
}