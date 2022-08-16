// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IERC721Oracle {
    /**
        @notice Fetches price of all the tokenIDs owned by the account for a token in terms of ETH
        @param token ERC721 token address
        @param account address of account
        @return price Price of all the token IDs owned by the account in terms of ETH
    */
    function getPrice(address token, address account) external view returns (uint256);

    /**
        @notice Fetches price of tokenID in terms of ETH
        @param tokenId ERC721 token ID
        @return price Price of token ID in terms of ETH
    */
    function getPrice(uint256 tokenId) external view returns (uint256);
}