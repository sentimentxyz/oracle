// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ICToken} from "./ICToken.sol";
import {IERC20} from "../utils/IERC20.sol";
import {IOracle} from "../core/IOracle.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";
/**
    @title Compound cToken oracle
    @notice Price oracle for cToken
*/
contract CTokenOracle is IOracle {
    using FixedPointMathLib for uint;

    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */

    /// @notice Oracle Facade
    IOracle public immutable oracle;

    /// @notice cEther
    address public immutable cETHER;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    /**
        @notice Contract constructor
        @param _oracle Oracle Facade
        @param _cETHER cEther
    */
    constructor(IOracle _oracle, address _cETHER) {
        oracle = _oracle;
        cETHER = _cETHER;
    }

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IOracle
    function getPrice(address token) external view returns (uint) {
        return (token == cETHER) ?
            getCEtherPrice() :
            getCErc20Price(ICToken(token), ICToken(token).underlying());
    }

    /* -------------------------------------------------------------------------- */
    /*                             INTERNAL FUNCTIONS                             */
    /* -------------------------------------------------------------------------- */

    function getCEtherPrice() internal view returns (uint) {
        /*
            cToken Exchange rates are scaled by 10^(18 - 8 + underlying token decimals) which comes
            out to 28 decimals for cEther. We must divide the exchange rate by 1e10 to scale it to
            18 decimals. Finally we multiply this with the price of the underlying token, in this
            case the price of ETH - 1e18. In the implementation below we combine these two ops and
            thus the cEther price can be computed as --
            exchangeRateStored() / 1e10 * 1e18 = exchangeRateStored * 1e8
        */
        return ICToken(cETHER).exchangeRateStored().mulWadDown(1e8);
    }

    function getCErc20Price(ICToken cToken, address underlying) internal view returns (uint) {
        /*
            cToken Exchange rates are scaled by 10^(18 - 8 + underlying token decimals) so to scale
            the exchange rate to 18 decimals we must multiply it by 1e8 and then divide it by the
            number of decimals in the underlying token. Finally to find the price of the cToken we
            must multiply this value with the current price of the underlying token
        */
        return cToken.exchangeRateStored()
        .mulDivDown(1e8 , 10 ** IERC20(underlying).decimals())
        .mulWadDown(oracle.getPrice(underlying));
    }
}