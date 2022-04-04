// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import {IOracle} from "../core/IOracle.sol";
import {Ownable} from "../utils/Ownable.sol";
import {IERC20} from "../utils/IERC20.sol";
import {PRBMathUD60x18} from "prb-math/PRBMathUD60x18.sol";

interface ICurvePool {
    function price_oracle(uint256) external view returns (uint256);

}

contract Curve3CryptoOracle is IOracle {
    using PRBMathUD60x18 for uint;
    
    address pool;
    address[3] assets;

    constructor(address _pool, address[3] memory _assets) {
        pool = _pool;
        assets = _assets;
    }

    function getPrice(address token) external view returns (uint price) {
        uint btcPrice = ICurvePool(pool).price_oracle(0);
        uint ethPrice = ICurvePool(pool).price_oracle(1);

        uint usdtBalance = 
            IERC20(assets[0]).balanceOf(pool).div(10 ** 6);
        uint btcBalance =
            IERC20(assets[1]).balanceOf(pool).div(10 ** 8);
        uint ethBalance = 
            IERC20(assets[2]).balanceOf(pool).div(10 ** 18);

        uint totalBalance = 
            (btcPrice.mul(btcBalance) + ethBalance.mul(ethPrice) + usdtBalance);

        uint totalSupply = 
            IERC20(token).totalSupply().div(10 ** 18);

        uint priceInUSD = totalBalance.div(totalSupply);

        return priceInUSD.div(ethPrice);
    }
}