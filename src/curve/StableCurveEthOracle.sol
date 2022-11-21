// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IOracle} from "../core/IOracle.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

interface ICurvePool {
    function coins(uint256) external view returns (address);
    function get_virtual_price() external view returns (uint256);
}

interface ICurveLP {
    function minter() external view returns (ICurvePool);
}

/**
    @title Stable curve oracle for ETH/Token(s) pair
    @notice Price Oracle for curve stable eth lp
*/
contract StableCurveEthOracle is IOracle {
    using FixedPointMathLib for uint;

    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */

    /// @notice Oracle Facade
    IOracle immutable oracleFacade;

    /// @notice WETH
    address immutable WETH;

    /// @notice number of coins in the pool
    uint immutable N_COINS;

    /// @notice ETH address used by curve
    address constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    /**
        @notice Contract constructor
        @param _oracle Address of oracleFacade
    */
    constructor(IOracle _oracle, address _WETH, uint _coins) {
        oracleFacade = _oracle;
        WETH = _WETH;
        N_COINS = _coins;
    }

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IOracle
    function getPrice(address token) external view returns (uint) {
        ICurvePool pool = ICurveLP(token).minter();

        address coin;
        uint price;
        uint minPrice = oracleFacade.getPrice(WETH);
        for(uint i; i<N_COINS; i++) {
            coin = pool.coins(i);
            if (coin != ETH) {
                price = oracleFacade.getPrice(coin);
                minPrice = (price < minPrice) ? price : minPrice;
            }
        }

        return minPrice.mulWadDown(pool.get_virtual_price());
    }
}