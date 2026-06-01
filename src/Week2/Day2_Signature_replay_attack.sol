// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


contract Vault {
    mapping(address => uint256) public balances;

    function deposit() payable external {
        balances[msg.sender] += msg.value;
    }

    function withdraw(address owner,uint256 amount,bytes32 messageHash,bytes memory signature) external {
        require(recoverSigner(messageHash,signature)==owner,"Invalid signature");
        balances[owner] -= amount;
        (bool ok,) = payable(msg.sender).call{value:amount}("");
        require(ok);
    }

    function recoverSigner(bytes32 hash,bytes memory sig) public pure returns(address){
        bytes32 r;
        bytes32 s;
        uint8 v;
        assembly{
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        return ecrecover(hash, v, r, s);
    }
}