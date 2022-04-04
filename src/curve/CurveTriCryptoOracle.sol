// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import {IOracle} from "../core/IOracle.sol";

interface ICurvePool {
    function price_oracle(uint256) external view returns (uint256);
    function virtual_price() external view returns (uint256);
    function A() external view returns (uint256);
    function gamma() external view returns (uint256);
}

// Implements https://twitter.com/curvefinance/status/1441538795493478415 in solidity

contract CurveTriCryptoOracle is IOracle {
    address pool;

    uint256 constant GAMMA0 = 28000000000000;
    uint256 constant A0 = 2 * 3**3 * 10000;
    uint256 constant DISCOUNT0 = 1087460000000000;

    constructor(address _pool) {
        pool = _pool;
    }

    function getPrice(address) external view returns (uint) {
        uint256 vp = ICurvePool(pool).virtual_price();
        uint256 p1 = ICurvePool(pool).price_oracle(0);
        uint256 p2 = ICurvePool(pool).price_oracle(1);

        uint256 maxPrice = 3 * vp * cubicRoot(p1 * p2) / 10**18;

        uint256 g = ICurvePool(pool).gamma() * 10**18 / GAMMA0;
        uint256 a = ICurvePool(pool).A() * 10**18 / A0;

        uint256 i = g**2 / 10**18 * a;
        uint256 j = 10**34;
        uint256 discount = i >= j ? i : j;
        
        discount = cubicRoot(discount) * DISCOUNT0 / 1e18;
        
        maxPrice -= maxPrice * discount / 10**18;
        return (maxPrice * 10 ** 18/p2);
    }

    function cubicRoot(uint256 x) internal pure returns (uint256) {
        uint256 D = x / 10**18;
        
        for (uint i=0; i < 255; i++) {    
            uint256 diff = 0;
            uint256 D_prev = D;
            
            D = D * 
                (2 * 10**18 + x / D * 10**18 / D * 10**18 / D) / 
                (3 * 10**18);

            if (D > D_prev) diff = D - D_prev;
            else diff = D_prev - D;
            if (diff <= 1 || diff * 10 ** 18 < D) return D;
        }
        revert("Did Not Converge");
    }
}