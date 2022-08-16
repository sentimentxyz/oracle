// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

interface IOracleFacade {
    /**
        @notice Fetches price of a given token in terms of ETH
        @param token Address of ERC20 token
        @return price Price of token in terms of ETH
    */
    function getPrice(address token) external view returns (uint);

    /**
        @notice Fetches price of all the tokenIDs owned by the account for a token in terms of ETH
        @param token Address of ERC721 token
        @param account Address of account
        @return price Price of token IDs owned by account in terms of ETH
    */
    function getPrice(address token, address account) external view returns (uint);

    /**
        @notice Fetches price of the tokenID of a given ERC721
        @param token Address of ERC721 token
        @param tokenId Token ID
        @return price Price of token IDs owned by account in terms of ETH
    */
    function getPrice(address token, uint256 tokenId) external view returns (uint);
}