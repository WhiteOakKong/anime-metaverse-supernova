// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { SuperNova } from "../src/Supernova.sol";

import { BaseScript } from "./Base.s.sol";

contract Deploy is BaseScript {
    function run() public broadcaster returns (SuperNova supernova) {
        address relayer;
        address soulMate;
        address burntSouls;
        address signer;
        address[] memory _legendaryAddresses = new address[](28);
        supernova = new SuperNova(_legendaryAddresses, burntSouls, soulMate, signer, relayer);
    }
}
