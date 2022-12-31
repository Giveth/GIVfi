// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./DonationHandler.sol";

contract DonationHandlerBridgeable is DonationHandler {
    bytes32 public constant VAULT_BRIDGE = keccak256("VAULT_BRIDGE");
    bool public withdrawLocked;

    /// @notice Initialize the contract.
    /// @param _acceptedToken Array of accepted tokens
    /// @param _donationReceiver Array of donation receivers
    /// @param _feeReceiver Array of fee receivers
    /// @param _admins Array of admins
    /// @param _vaultBridge vault bridge address
    /// @param _withdrawLocked withdraw enabled
    function initialize(
        address[] calldata _acceptedToken,
        address[] calldata _donationReceiver,
        address[] calldata _feeReceiver,
        address[] calldata _admins,
        address _vaultBridge,
        bool _withdrawLocked
    ) public initializer {
        __DonationHandler_init(_acceptedToken, _donationReceiver, _feeReceiver, _admins);
        _setupRole(VAULT_BRIDGE, _vaultBridge);
        withdrawLocked = _withdrawLocked;
    }

    // ################## Withdraw Lock ##################

    function _withdraw(address _token, address _from, address _to, uint256 _amount) internal override {
        if (withdrawLocked) revert WithdrawLocked();
        super._withdraw(_token, _from, _to, _amount);
    }

    /// @notice set withdraw lock
    /// @param _withdrawLocked withdraw lock
    function setWithdrawLocked(bool _withdrawLocked) external {
        _checkAdmin(msg.sender);
        withdrawLocked = _withdrawLocked;
    }

    // ################## Vault Bridge Role ##################

    /// @notice Internal function. Checks if an address is the vault bridge and reverts NotVaultBridge() if address is not the vault bridge.
    /// @param _vaultBridge The address to check.
    function _checkVaultBridge(address _vaultBridge) internal view {
        if (!hasRole(VAULT_BRIDGE, _vaultBridge)) revert NotVaultBridge();
    }

    /// @notice Assigns address to vault bridge role. Can only be called by an admin.
    /// @param _vaultBridge The address to assign to vault bridge role.
    function addVaultBridge(address _vaultBridge) external {
        _checkAdmin(msg.sender);
        _setupRole(VAULT_BRIDGE, _vaultBridge);
    }

    /// @notice Removes address from vault bridge role. Can only be called by an admin.
    /// @param _vaultBridge The address to remove from vault bridge role.
    function removeVaultBridge(address _vaultBridge) external {
        _checkAdmin(msg.sender);
        _revokeRole(VAULT_BRIDGE, _vaultBridge);
    }

    /// @notice Wrapper function to check if an address is a vault bridge.
    /// @param _vaultBridge The address to check.
    /// @return bool True if address is a vault bridge, false otherwise.
    function isVaultBridge(address _vaultBridge) external view returns (bool) {
        return hasRole(VAULT_BRIDGE, _vaultBridge);
    }

    /// @notice Throws if called by any account other than the vault bridge.
    error NotVaultBridge();

    /// @notice Throws if withdraw is locked.
    error WithdrawLocked();
}
