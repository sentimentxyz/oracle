// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {IOracle} from "../core/IOracle.sol";
import {IUniswapV2Pair} from "./IUniswapV2Pair.sol";
import {PRBMathUD60x18} from "prb-math/PRBMathUD60x18.sol";

contract UniV2LPOracle is IOracle {
    using PRBMathUD60x18 for uint;

    IOracle public immutable oracle;

    constructor(IOracle _oracle) {
        oracle = _oracle;
    }

    // Adapted from https://blog.alphaventuredao.io/fair-lp-token-pricing
    function getPrice(address pair) external view returns (uint) {
        uint p0 = oracle.getPrice(IUniswapV2Pair(pair).token0());
        uint p1 = oracle.getPrice(IUniswapV2Pair(pair).token1());
        uint totalSupply = IUniswapV2Pair(pair).totalSupply();
        (uint r0, uint r1,) = IUniswapV2Pair(pair).getReserves();
        return r0.mul(r1).sqrt().div(totalSupply).mul(p0.mul(p1).sqrt()).mul(2e18);
    }
}