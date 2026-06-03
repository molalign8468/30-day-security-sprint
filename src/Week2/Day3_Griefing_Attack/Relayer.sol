// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Relayer {
    mapping(bytes32 => bool) public executed;
    address public owner;

    event TransactionRelayed(bytes32 indexed txHash, bool success);
    event Funded(address indexed sender, uint256 amount);

    constructor() payable {
       owner = msg.sender;
    }

    function relay(
        address target,
        bytes calldata data,
        uint256 gasLimit, 
        bytes32 txHash
        ) external {

     require(!executed[txHash], "Relayer: already executed");
     executed[txHash] = true;

     (bool success, ) = target.call{gas: gasLimit}(data);
     emit TransactionRelayed(txHash, success);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }


    receive() external payable {
        emit Funded(msg.sender, msg.value);
    }
}