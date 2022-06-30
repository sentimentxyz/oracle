// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IOracle} from "../core/IOracle.sol";

interface ICurvePool {
    function A() external view returns (uint256);
    function gamma() external view returns (uint256);
    function virtual_price() external view returns (uint256);
    function price_oracle(uint256) external view returns (uint256);
}

// eth:0xE8b2989276E2Ca8FDEA2268E3551b2b4B2418950
// https://twitter.com/curvefinance/status/1441538795493478415

/**
    @title Curve tri crypto oracle
    @notice Price Oracle for crv3crypto
*/
contract CurveTriCryptoOracle is IOracle {

    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */

    /// @notice curve tri crypto pool address
    address immutable pool;

    /* -------------------------------------------------------------------------- */
    /*                             CONSTANT VARIABLES                             */
    /* -------------------------------------------------------------------------- */

    uint constant GAMMA0 = 28000000000000;
    uint constant A0 = 2 * 3**3 * 10000;
    uint constant DISCOUNT0 = 1087460000000000;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    /**
        @notice Contract constructor
        @param _pool curve tri crypto pool address
    */
    constructor(address _pool) {
        pool = _pool;
    }

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IOracle
    function getPrice(address) external view returns (uint) {
        uint g = ICurvePool(pool).gamma() * 1e18 / GAMMA0;
        uint a = ICurvePool(pool).A() * 1e18 / A0;
        uint i = g ** 2 / 1e18 * a;
        i = (i >= 1e34) ? cubicRoot(i) * DISCOUNT0 / 1e18
            : cubicRoot(1e34) * DISCOUNT0 / 1e18;

        uint vp = ICurvePool(pool).virtual_price();
        uint p1 = ICurvePool(pool).price_oracle(0); // WBTC price
        uint p2 = ICurvePool(pool).price_oracle(1); // WETH price
        uint maxPrice = 3 * vp * cubicRoot(p1 * p2) / 1e18;
        maxPrice -= maxPrice * i / 1e18;

        return (maxPrice * 1e18 / p2);
    }

    /* -------------------------------------------------------------------------- */
    /*                             INTERNAL FUNCTIONS                             */
    /* -------------------------------------------------------------------------- */

    function cubicRoot(uint x) internal pure returns (uint) {
        uint D = x / 1e18;
        for (uint i; i < 255;) {
            uint D_prev = D;
            D = D * (2e18 + x / D * 1e18 / D * 1e18 / D) / (3e18);
            uint diff = (D > D_prev) ? D - D_prev : D_prev - D;
            if (diff < 2 || diff * 1e18 < D) return D;
            unchecked { ++i; }
        }
        revert("Did Not Converge");
    }
}