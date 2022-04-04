// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import {IOracle} from "../core/IOracle.sol";
import {Ownable} from "../utils/Ownable.sol";
import {IERC20} from "../utils/IERC20.sol";
import {PRBMathUD60x18} from "@prb-math/contracts/PRBMathUD60x18.sol";

interface ICurvePool {
    function price_oracle(uint256) external view returns (uint256);

}

contract Curve3CryptoOracle is IOracle {
    using PRBMathUD60x18 for uint;
    
    address pool;
    address[3] assets;
    
    uint8 token_decimals;
    uint8[3] decimals;

    constructor(address _pool, address[3] memory _assets, uint8 _decimals) {
        pool = _pool;
        assets = _assets;
        decimals[0] = IERC20(assets[0]).decimals();
        decimals[1] = IERC20(assets[1]).decimals();
        decimals[2] = IERC20(assets[2]).decimals();
        token_decimals = _decimals;
    }

    function getPrice(address token) external view returns (uint price) {
        uint btcPrice = ICurvePool(pool).price_oracle(0);
        uint ethPrice = ICurvePool(pool).price_oracle(1);

        uint usdtBalance = 
            IERC20(assets[0]).balanceOf(pool).div(10 ** decimals[0]);
        uint btcBalance =
            IERC20(assets[1]).balanceOf(pool).div(10 ** decimals[1]);
        uint ethBalance = 
            IERC20(assets[2]).balanceOf(pool).div(10 ** decimals[2]);

        uint totalBalance = 
            (btcPrice.mul(btcBalance) + ethBalance.mul(ethPrice) + usdtBalance);

        uint totalSupply = 
            IERC20(token).totalSupply().div(10 ** token_decimals);

        uint priceInUSD = totalBalance.div(totalSupply);

        return priceInUSD.div(ethPrice);
    }
}