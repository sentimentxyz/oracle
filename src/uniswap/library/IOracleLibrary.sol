// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IOracleLibrary {
    function consult(address pool, uint32 secondsAgo)
        external
        view
        returns (int24 arithmeticMeanTick, uint128 harmonicMeanLiquidity);

    function getQuoteAtTick(
        int24 tick,
        uint128 baseAmount,
        address baseToken,
        address quoteToken
    ) external pure returns (uint256 quoteAmount);
}