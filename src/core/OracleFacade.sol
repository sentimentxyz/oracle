// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {IOracle} from "./IOracle.sol";
import {Errors} from "../utils/Errors.sol";
import {Ownable} from "../utils/Ownable.sol";

contract OracleFacade is Ownable, IOracle {
    address public immutable WETH;

    mapping(address => IOracle) public oracle;

    event UpdateFeed(address indexed tokenAddr, address indexed feedAddr);

    // TODO Should WETH_ADDR be mutable?
    constructor(address weth) Ownable(msg.sender) {
        WETH = weth;
    }

    /// @dev Assume that the response has 18 decimals
    function getPrice(address token) external view returns (uint) {
        if(token == address(0) || token == WETH) return 1e18;
        if(address(oracle[token]) == address(0)) revert Errors.PriceUnavailable();
        return oracle[token].getPrice(token);
    }

     // AdminOnly
    function setFeed(address token, IOracle _oracle) external adminOnly {
        oracle[token] = _oracle;
        emit UpdateFeed(token, address(_oracle));
    }
}