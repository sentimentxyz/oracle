// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {IAToken} from "./IAToken.sol";
import {IOracle} from "../core/IOracle.sol";

contract ATokenOracle is IOracle {
    IOracle public immutable oracle;

    constructor(IOracle _oracle) {
        oracle = _oracle;
    }

    function getPrice(address aToken) external view returns (uint) {
        return oracle.getPrice( IAToken(aToken).UNDERLYING_ASSET_ADDRESS() );
    }
}