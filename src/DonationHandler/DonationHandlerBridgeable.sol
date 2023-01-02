// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./DonationHandler.sol";
import "./interface/IDonationHandlerBridgeable.sol";
import "../Vault/interfaces/IVaultBridge.sol";

contract DonationHandlerBridgeable is DonationHandler {
    using SafeERC20 for IERC20;

    address public vaultBridge;
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
        uint256 _minFee,
        address _vaultBridge,
        bool _withdrawLocked
    ) public initializer {
        __DonationHandler_init(_acceptedToken, _donationReceiver, _feeReceiver, _admins, _minFee);
        vaultBridge = _vaultBridge;
        withdrawLocked = _withdrawLocked;
    }

    // ################## Withdraw Lock ##################

    function _withdraw(address _token, address _from, address _to, uint256 _amount) internal override {
        if (withdrawLocked) revert WithdrawLocked();
        if ( // todo: handle multiple assets properly
            vaultBridge != address(0) && IVaultBridge(vaultBridge).getAsset() == _token
                && balances[_from][_token] <= _amount && IERC20(_token).balanceOf(address(this)) < _amount
        ) {
            IVaultBridge(vaultBridge).withdraw(_amount);
        }
        super._withdraw(_token, _from, _to, _amount);
    }

    /// @notice set withdraw lock
    /// @param _withdrawLocked withdraw lock
    function setWithdrawLocked(bool _withdrawLocked) external {
        _checkAdmin(msg.sender);
        withdrawLocked = _withdrawLocked;
    }

    // ################## Vault Bridge Role ##################

    /// @notice Internal function. Checks if msg.sender is the vault bridge and reverts NotVaultBridge() if address is not the vault bridge.
    function _checkVaultBridge() internal view {
        if (msg.sender != vaultBridge) revert NotVaultBridge();
    }

    /// @notice Assigns address to vault bridge role. Can only be called by an admin.
    /// @param _vaultBridge The address to assign to vault bridge role.
    function setVaultBridge(address _vaultBridge) external {
        _checkAdmin(msg.sender);
        vaultBridge = _vaultBridge;
        emit VaultBridgeSet(_vaultBridge);
    }

    /// @notice Wrapper function to check if an address is a vault bridge.
    /// @param _vaultBridge The address to check.
    /// @return bool True if address is a vault bridge, false otherwise.
    function isVaultBridge(address _vaultBridge) external view returns (bool) {
        return _vaultBridge == vaultBridge;
    }

    // ################## Special Bridge Functions ##################

    function take(address _token, uint256 _amount) external {
        _checkVaultBridge();
        IERC20(_token).safeTransfer(msg.sender, _amount);

        emit Take(_token, msg.sender, _amount);
    }

    /// @notice Throws if called by any account other than the vault bridge.
    error NotVaultBridge();

    /// @notice Throws if withdraw is locked.
    error WithdrawLocked();

    event Take(address indexed token, address indexed to, uint256 amount);
    event VaultBridgeSet(address indexed vaultBridge);
}
