// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Errors} from "../utils/Errors.sol";
import {IOracle} from "../core/IOracle.sol";
import {Ownable} from "../utils/Ownable.sol";
import {OracleLibrary} from "./library/OracleLibrary.sol";
import {IERC20} from "../utils/IERC20.sol";

/**
    @title Uniswap V3 TWAP Oracle
    @notice Price oracle that uses univ3 token-weth pools to fetch price of
    a given token in terms of ETH
*/
contract UniV3TWAPOracle is Ownable, IOracle {

    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */

    /// @notice TWAP period, default = 1800 seconds
    uint32 public twapPeriod = 1800;

    /// @notice arbi:WETH
    address public constant WETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;

    /// @notice mapping of token to token-WETH Uniswap v3 pool
    mapping(address => address) poolFor;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    constructor() Ownable(msg.sender) {}

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IOracle
    function getPrice(address token) public view returns (uint256) {

        address pool;
        if ((pool = poolFor[token]) == address(0)) {
            revert Errors.PriceUnavailable();
        }

        (int24 arithmeticMeanTick, ) = OracleLibrary.consult(
            pool,
            twapPeriod
        );

        return OracleLibrary.getQuoteAtTick(
            arithmeticMeanTick,
            uint128(10) ** IERC20(token).decimals(),
            token,
            WETH
        );
    }

    /* -------------------------------------------------------------------------- */
    /*                               ADMIN FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /**
        @notice Update twap period
        @param _twapPeriod New twap period in seconds
    */
    function updateTwapPeriod(uint32 _twapPeriod) external adminOnly {
        twapPeriod = _twapPeriod;
    }

    /**
        @notice Set Uniswap v3 WETH-token pool for a given token
        @param token Address of token
        @param pool Address of pool
    */
    function setPool(address token, address pool) external adminOnly {
        poolFor[token] = pool;
    }
}