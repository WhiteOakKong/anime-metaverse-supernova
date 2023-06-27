// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19;

import { SuperNova } from "../src/Supernova.sol";
import { BurntSouls } from "../src/BurntSouls.sol";

import { BaseScript } from "./Base.s.sol";

contract Deploy is BaseScript {
    function run() public broadcaster returns (SuperNova supernova, BurntSouls burntSouls) {
        address relayer;
        address soulMate;
        address signer;
        address[] memory _legendaryAddresses = new address[](28);
        burntSouls = new BurntSouls();
        supernova = new SuperNova(_legendaryAddresses, address(burntSouls), soulMate, signer, relayer);
    }
}
