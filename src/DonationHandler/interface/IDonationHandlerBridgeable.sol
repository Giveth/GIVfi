// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./IDonationHandler.sol";

interface IDonationHandlerBridgeable is IDonationHandler {
    function setWithdrawLocked(bool _withdrawLocked) external;

    function setVaultBridge(address _vaultBridge) external;

    function isVaultBridge(address _vaultBridge) external view returns (bool);

    function take(address _token, uint256 _amount) external;
}
