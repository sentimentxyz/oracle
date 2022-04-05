// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import {DSTest} from "ds-test/test.sol";
import {CurveTriCryptoOracle} from "../curve/CurveTriCryptoOracle.sol";

contract CurveOracleTest is DSTest {
    CurveTriCryptoOracle tricrypto;
    function setUp() public {
        tricrypto = new CurveTriCryptoOracle(0xD51a44d3FaE010294C616388b506AcdA1bfAAE46);
    }

    function testOracle() public {
        emit log_uint(tricrypto.getPrice(0xc4AD29ba4B3c580e6D59105FFf484999997675Ff));
    }
}