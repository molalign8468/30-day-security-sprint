// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Vault {
    mapping(address => uint) public balances;
    address public relayer;

    event Deposited(address indexed user,uint amount);
    event Withdraw(address indexed user,uint amount);

    constructor(address _relayer) {
        relayer = _relayer;
    }

    modifier onlyRelayer() {
        require(msg.sender==relayer,"Vault: only relayer");
        _;
    }


    function deposit() payable external {
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender,msg.value);
    }

    function withdraw(address user,uint amount) external onlyRelayer {
        require(balances[user] >= amount, "Vault: insufficient balance");
        balances[user] -= amount;
        _logWithdrawal(user, amount);

        (bool ok,) = user.call{value:amount}("");
        require(ok,"Vault: ETH transfer failed");
        emit Withdraw(user, amount);
    }

    function _logWithdrawal(address user, uint256 amount) internal {
        // Simulate storage writes that consume gas
        bytes32 slot;
        assembly {
            // Write to a pseudo-random storage slot to burn gas
            mstore(0, user)
            mstore(32, amount)
            slot := keccak256(0, 64)
            sstore(slot, 1)
        }
    }

    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }

    receive() external payable{}
}