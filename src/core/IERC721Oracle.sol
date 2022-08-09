// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IERC721Oracle {
    /**
        @notice Returns price of tokenID in ETH
        @param token ERC721 token address
        @param account address of account
        @return price Price of all the token IDs owned by the account in terms of ETH
    */
    function getPrice(address token, address account) external view returns (uint256);
}