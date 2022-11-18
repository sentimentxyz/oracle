// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IOracle} from "../core/IOracle.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";

interface ICurvePool {
    function coins(uint256) external view returns (address);
    function get_virtual_price() external view returns (uint256);
}

/**
    @title Stable 2 curve oracle for ETH/Token pair
    @notice Price Oracle for 2 curve stable eth lp
*/
contract Stable2CurveEthOracle is IOracle {
    using FixedPointMathLib for uint;

    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */

    /// @notice Oracle Facade
    IOracle immutable oracleFacade;

    ICurvePool immutable pool;

    address immutable WETH;

    address immutable TOKEN;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    /**
        @notice Contract constructor
        @param _oracle Address of oracleFacade
    */
    constructor(IOracle _oracle, address _WETH, ICurvePool _pool, address _token) {
        oracleFacade = _oracle;
        pool = _pool;
        WETH = _WETH;
        TOKEN = _token;
    }

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IOracle
    function getPrice(address) external view returns (uint) {
        uint price0 = oracleFacade.getPrice(WETH);
        uint price1 = oracleFacade.getPrice(TOKEN);
        return ((price0 < price1) ? price0 : price1).mulWadDown(
            pool.get_virtual_price()
        );
    }
}