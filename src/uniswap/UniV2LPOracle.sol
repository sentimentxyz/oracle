// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {IOracle} from "../core/IOracle.sol";
import {IUniswapV2Pair} from "./IUniswapV2Pair.sol";
import {PRBMathUD60x18} from "prb-math/PRBMathUD60x18.sol";

/**
    @title Uniswap v2 LP Oracle
    @notice Price oracle for uniswap v2 LP Tokens
*/
contract UniV2LpOracle is IOracle {
    using PRBMathUD60x18 for uint;

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @notice Oracle Facade
    IOracle public immutable oracle;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    /**
        @notice Contract constructor
        @param _oracle Address of Oracle Facade
    */
    constructor(IOracle _oracle) {
        oracle = _oracle;
    }

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @dev Adapted from https://blog.alphaventuredao.io/fair-lp-token-pricing
    /// @inheritdoc IOracle
    function getPrice(address pair) external view returns (uint) {
        (uint r0, uint r1,) = IUniswapV2Pair(pair).getReserves();

        // 2 * sqrt(r0 * r1) * sqrt(p0 * p1) / totalSupply
        return r0
            .gm(r1)
            .div(IUniswapV2Pair(pair).totalSupply())
            .mul(
                oracle.getPrice(IUniswapV2Pair(pair).token0())
                .gm(oracle.getPrice(IUniswapV2Pair(pair).token1()))
            ).mul(2e18);
    }
}