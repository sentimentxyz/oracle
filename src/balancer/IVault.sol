// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IAsset} from "./IAsset.sol";

interface IVault {
     /**
     * @dev Data for `manageUserBalance` operations, which include the possibility for ETH to be sent and received
     without manual WETH wrapping or unwrapping.
     */
    struct UserBalanceOp {
        UserBalanceOpKind kind;
        IAsset asset;
        uint256 amount;
        address sender;
        address payable recipient;
    }

    enum UserBalanceOpKind { DEPOSIT_INTERNAL, WITHDRAW_INTERNAL, TRANSFER_INTERNAL, TRANSFER_EXTERNAL }

    function getPoolTokens(bytes32) external view returns (address[] memory, uint256[] memory, uint256);
    function manageUserBalance(UserBalanceOp[] memory ops) external;
}