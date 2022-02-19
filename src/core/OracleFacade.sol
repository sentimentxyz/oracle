// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {Errors} from "../utils/Errors.sol";
import {IPriceFeed} from "./IPriceFeed.sol";
import {Ownable} from "../utils/Ownable.sol";

contract OracleFacade is Ownable, IPriceFeed {
    address public immutable WETH_ADDR;

    mapping(address => address) public priceFeed;

    event UpdateFeed(address indexed tokenAddr, address indexed feedAddr);

    // TODO Should WETH_ADDR be mutable?
    constructor(address wethAddress) Ownable(msg.sender) {
        WETH_ADDR = wethAddress;
    }

    /// @dev Assume that the response has 18 decimals
    function getPrice(address token) external view returns (uint) {
        if(token == address(0) || token == WETH_ADDR) return 1e18;
        if(priceFeed[token] == address(0)) revert Errors.PriceUnavailable();
        return IPriceFeed(priceFeed[token]).getPrice(token);
    }

     // AdminOnly
    function setFeed(address token, address _priceFeed) external adminOnly {
        priceFeed[token] = _priceFeed;
        emit UpdateFeed(token, priceFeed[token]);
    }
}