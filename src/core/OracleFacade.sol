// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {IOracle} from "./IOracle.sol";
import {Errors} from "../utils/Errors.sol";
import {Ownable} from "../utils/Ownable.sol";
import {IERC721Oracle} from "./IERC721Oracle.sol";
import {IOracleFacade} from "./IOracleFacade.sol";

/**
    @title Oracle Facade
    @notice This contract acts as a single interface for the client to fetch
    price of a given token in terms of eth
*/
contract OracleFacade is Ownable, IOracleFacade {

    /* -------------------------------------------------------------------------- */
    /*                               STATE VARIABLES                              */
    /* -------------------------------------------------------------------------- */

    /// @notice Mapping of erc20 token to Price Oracle for the token
    mapping(address => IOracle) public erc20Oracle;

    /// @notice Mapping of erc721 token to Price Oracle for the token
    mapping(address => IERC721Oracle) public erc721Oracle;

    /* -------------------------------------------------------------------------- */
    /*                                 CONSTRUCTOR                                */
    /* -------------------------------------------------------------------------- */

    /// @notice Contract Constructor
    constructor() Ownable(msg.sender) {}

    /* -------------------------------------------------------------------------- */
    /*                                   EVENTS                                   */
    /* -------------------------------------------------------------------------- */

    event UpdateOracle(address indexed token, address indexed feed);

    /* -------------------------------------------------------------------------- */
    /*                              PUBLIC FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    /// @inheritdoc IOracleFacade
    function getPrice(address token) external view returns (uint) {
        if(address(erc20Oracle[token]) == address(0)) revert Errors.PriceUnavailable();
        return erc20Oracle[token].getPrice(token);
    }

    /// @inheritdoc IOracleFacade
    function getPrice(address token, address account) external view returns (uint) {
        if(address(erc721Oracle[token]) == address(0)) revert Errors.PriceUnavailable();
        return erc721Oracle[token].getPrice(token, account);
    }

    /// @inheritdoc IOracleFacade
    function getPrice(address token, uint256 tokenId) external view returns (uint) {
        if(address(erc721Oracle[token]) == address(0)) revert Errors.PriceUnavailable();
        return erc721Oracle[token].getPrice(tokenId);
    }

    /* -------------------------------------------------------------------------- */
    /*                               ADMIN FUNCTIONS                              */
    /* -------------------------------------------------------------------------- */

    function setERC20Oracle(address token, IOracle _oracle) external adminOnly {
        erc20Oracle[token] = _oracle;
        emit UpdateOracle(token, address(_oracle));
    }

    function setERC721Oracle(address token, IERC721Oracle _oracle) external adminOnly {
        erc721Oracle[token] = _oracle;
        emit UpdateOracle(token, address(_oracle));
    }
}