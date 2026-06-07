// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


contract PuzzleProxy {
    address public pendingAdmin; // slot 0
    address public admin;        // slot 1

    address public implementation;

    constructor(address _implementation) {
        implementation = _implementation;
        admin = msg.sender;
    }

    function proposeNewAdmin(address _newAdmin) external {
        pendingAdmin = _newAdmin;
    }

    fallback() external payable {
        address impl = implementation;

        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(
                gas(),
                impl,
                0,
                calldatasize(),
                0,
                0
            )

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    receive() external payable {}
}