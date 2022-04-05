// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import {IOracle} from "../core/IOracle.sol";

interface IYVault {
    function token() external view returns (address);
    function pricePerShare() external view returns (uint256);
}

contract YTokenOracle is IOracle {
    
    IOracle public oracle;

    constructor(IOracle _oracle) {
        oracle = _oracle;
    }

    function getPrice(address token) external view returns (uint price) {
        price = oracle.getPrice(IYVault(token).token()) * 
            IYVault(token).pricePerShare() / 1e18;
    }
}