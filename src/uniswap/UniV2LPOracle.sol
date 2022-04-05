// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {IOracle} from "../core/IOracle.sol";
import {IUniswapV2Pair} from "./IUniswapV2Pair.sol";
import {PRBMathUD60x18} from "prb-math/PRBMathUD60x18.sol";

contract UniV2LpOracle is IOracle {
    using PRBMathUD60x18 for uint;

    IOracle public immutable oracle;

    constructor(IOracle _oracle) {
        oracle = _oracle;
    }

    // Adapted from https://blog.alphaventuredao.io/fair-lp-token-pricing
    function getPrice(address pair) external view returns (uint) {
        uint totalSupply = IUniswapV2Pair(pair).totalSupply();
        uint p0 = oracle.getPrice(IUniswapV2Pair(pair).token0());
        uint p1 = oracle.getPrice(IUniswapV2Pair(pair).token1());
        (uint r0, uint r1,) = IUniswapV2Pair(pair).getReserves();
        
        // 2 * sqrt(r0 * r1) * sqrt(p0 * p1) / totalSupply
        return r0.gm(r1).div(totalSupply).mul(p0.gm(p1)).mul(2e18);
    }
}