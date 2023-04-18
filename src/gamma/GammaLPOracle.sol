// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC20} from "../utils/IERC20.sol";
import {IOracle} from "../core/IOracle.sol";
import {IHypervisor} from "./IHypervisor.sol";
import {SafeCast} from "./libraries/SafeCast.sol";
import {TickMath} from "../uniswap/library/TickMath.sol";
import {LiquidityAmounts} from "./libraries/LiquidityAmounts.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

/**
 * @title Gamma LP Oracle
 * @notice Price oracle for Gamma LP Tokens
 */
contract GammaLPOracle is IOracle {
    using FixedPointMathLib for uint256;
    using SafeCast for uint256;

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @notice Oracle Facade
    IOracle public immutable oracle;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    /**
     * @notice Contract constructor
     *     @param _oracle Address of Oracle Facade
     */
    constructor(IOracle _oracle) {
        oracle = _oracle;
    }

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IOracle
    function getPrice(address pair) external returns (uint256) {
        address token0 = IHypervisor(pair).token0();
        address token1 = IHypervisor(pair).token1();

        uint256 price0 = oracle.getPrice(token0);
        uint256 price1 = oracle.getPrice(token1);

        uint256 decimals0 = IERC20(token0).decimals();
        uint256 decimals1 = IERC20(token1).decimals();

        uint160 sqrtPrice = (
            (FixedPointMathLib.sqrt(((price0 * 10 ** (36 + decimals0 - decimals1)) / price1)) << 96) / 1e18
        ).toUint160();

        (uint128 liquidity,,) = IHypervisor(pair).getBasePosition();

        (uint256 b0, uint256 b1) = LiquidityAmounts.getAmountsForLiquidity(
            sqrtPrice,
            TickMath.getSqrtRatioAtTick(IHypervisor(pair).baseLower()),
            TickMath.getSqrtRatioAtTick(IHypervisor(pair).baseUpper()),
            liquidity
        );

        (liquidity,,) = IHypervisor(pair).getLimitPosition();

        (uint256 l0, uint256 l1) = LiquidityAmounts.getAmountsForLiquidity(
            sqrtPrice,
            TickMath.getSqrtRatioAtTick(IHypervisor(pair).limitLower()),
            TickMath.getSqrtRatioAtTick(IHypervisor(pair).limitUpper()),
            liquidity
        );

        uint256 r0 = b0 + l0 + IERC20(token0).balanceOf(pair);
        uint256 r1 = b1 + l1 + IERC20(token1).balanceOf(pair);
        if (decimals0 <= 18) {
            r0 = r0 * 10 ** (18 - decimals0);
        } else {
            r0 = r0 / 10 ** (decimals0 - 18);
        }

        if (decimals1 <= 18) {
            r1 = r1 * 10 ** (18 - decimals1);
        } else {
            r1 = r1 / 10 ** (decimals1 - 18);
        }

        return (r0.mulWadDown(price0) + r1.mulWadDown(price1)).divWadDown(IHypervisor(pair).totalSupply());
    }
}
