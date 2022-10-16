// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {AccessControlUpgradeable as AccessControl} from
    "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract DonationHandlerRoles is AccessControl {
    bytes32 public constant ACCEPTED_TOKEN = keccak256("ACCEPTED_TOKEN");
    bytes32 public constant DONATION_RECIPIENT = keccak256("DONATION_RECIPIENT");
    bytes32 public constant FEE_RECEIVER = keccak256("FEE_RECEIVER");
    bytes32 public constant ADMIN = keccak256("ADMIN");

    /// @notice Initializes the contract settings by adding all addresses to their roles.
    /// @param _acceptedToken The list of accepted tokens.
    /// @param _donationRecipient The list of donation recipients.
    /// @param _feeReceiver The list of fee receivers.
    /// @param _admins The list of admins.
    function __DonationHandlerRoles_init(
        address[] calldata _acceptedToken,
        address[] calldata _donationRecipient,
        address[] calldata _feeReceiver,
        address[] calldata _admins
    ) internal onlyInitializing {
        __AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

        _setRoleAdmin(ACCEPTED_TOKEN, ADMIN);
        _setRoleAdmin(DONATION_RECIPIENT, ADMIN);
        _setRoleAdmin(FEE_RECEIVER, ADMIN);

        _addRoles(ACCEPTED_TOKEN, _acceptedToken);
        _addRoles(DONATION_RECIPIENT, _donationRecipient);
        _addRoles(FEE_RECEIVER, _feeReceiver);
        _addRoles(ADMIN, _admins);
    }

    /// @notice Internal function. Adds a list of addresses to a role.
    /// @param _role The role to add the addresses to.
    /// @param _addresses The list of addresses to add to the role.
    function _addRoles(bytes32 _role, address[] calldata _addresses) internal {
        uint256 length = _addresses.length;
        for (uint256 i = 0; i < length;) {
            _setupRole(_role, _addresses[i]);
            unchecked {
                i++;
            }
        }
    }

    /// @notice Internal function. Removes a list of addresses from a role.
    /// @param _role The role to remove the addresses from.
    /// @param _addresses The list of addresses to remove from the role.
    function _removeRoles(bytes32 _role, address[] calldata _addresses) internal {
        uint256 length = _addresses.length;
        for (uint256 i = 0; i < length;) {
            revokeRole(_role, _addresses[i]);
            unchecked {
                i++;
            }
        }
    }

    /// @notice Internal function. Checks if an address is admin and reverts NotAdmin() if address is not an admin.
    function _checkAdmin(address _address) internal view {
        if (!hasRole(ADMIN, _address)) revert NotAdmin();
    }

    /// @notice Assigns addresses to admin role. Can only be called by an admin.
    /// @param _admins Array of addresses to assign to admin role.
    function addAdmin(address[] calldata _admins) external {
        _checkAdmin(msg.sender);
        _addRoles(ADMIN, _admins);
    }

    /// @notice Removes addresses from admin role. Can only be called by default admin.
    /// @param _admins Array of addresses to remove from admin role.
    function removeAdmin(address[] calldata _admins) external {
        if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) revert NotDefaultAdmin();
        _removeRoles(ADMIN, _admins);
    }

    //// @notice Revoke admin themself from admin role.
    function revokeAdmin() external {
        _checkAdmin(msg.sender);
        _revokeRole(ADMIN, msg.sender);
    }

    /// @notice Wrapper function to check if an address is admin.
    /// @param _account The address to check.
    /// @return bool True if address is admin, false otherwise.
    function isAdmin(address _account) external view returns (bool) {
        return hasRole(ADMIN, _account);
    }

    /// @notice Internal function. Checks if an address is a whiteisted token and reverts TokenNotAccepted() if address is not whitelisted.
    /// @param _token The address to check.
    function _checkToken(address _token) internal view {
        if (!hasRole(ACCEPTED_TOKEN, _token)) revert TokenNotAccepted();
    }

    /// @notice Assigns addresses to accepted token role. Can only be called by an admin.
    /// @param _token Array of addresses to assign to accepted token role.
    function addToken(address[] calldata _token) external {
        _checkAdmin(msg.sender);
        _addRoles(ACCEPTED_TOKEN, _token);
    }

    /// @notice Removes addresses from accepted token role. Can only be called by an admin.
    /// @param _token Array of addresses to remove from accepted token role.
    function removeToken(address[] calldata _token) external {
        _checkAdmin(msg.sender);
        _removeRoles(ACCEPTED_TOKEN, _token);
    }

    /// @notice Wrapper function to check if an address is a whitelisted token.
    /// @param _token The address to check.
    /// @return bool True if address is whitelisted, false otherwise.
    function isTokenAccepted(address _token) external view returns (bool) {
        return hasRole(ACCEPTED_TOKEN, _token);
    }

    /// @notice Internal function. Checks if an address is a donation recipient and reverts RecipientNotAccepted() if address is not a donation recipient.
    /// @param _recipient The address to check.
    function _checkDonationRecipient(address _recipient) internal view {
        if (!hasRole(DONATION_RECIPIENT, _recipient)) {
            revert RecipientNotAccepted();
        }
    }

    /// @notice Assigns addresses to donation recipient role. Can only be called by an admin.
    /// @param _recipients Array of addresses to assign to donation recipient role.
    function addDonationRecipient(address[] calldata _recipients) external {
        _checkAdmin(msg.sender);
        _addRoles(DONATION_RECIPIENT, _recipients);
    }

    /// @notice Removes addresses from donation recipient role. Can only be called by an admin.
    /// @param _recipients Array of addresses to remove from donation recipient role.
    function removeDonationRecipient(address[] calldata _recipients) external {
        _checkAdmin(msg.sender);
        _removeRoles(DONATION_RECIPIENT, _recipients);
    }

    /// @notice Wrapper function to check if an address is a donation recipient.
    /// @param _recipient The address to check.
    /// @return bool True if address is a donation recipient, false otherwise.
    function isDonationRecipient(address _recipient) external view returns (bool) {
        return hasRole(DONATION_RECIPIENT, _recipient);
    }

    /// @notice Internal function. Checks if an address is a fee receiver and reverts NotFeeReceiver() if address is not a fee receiver.
    /// @param _receiver The address to check.
    function _checkFeeReceiver(address _receiver) internal view {
        if (!hasRole(FEE_RECEIVER, _receiver)) revert NotFeeReceiver();
    }

    /// @notice Assigns addresses to fee receiver role. Can only be called by an admin.
    /// @param _feeReceiver Array of addresses to assign to fee receiver role.
    function addFeeReceiver(address[] calldata _feeReceiver) external {
        _checkAdmin(msg.sender);
        _addRoles(FEE_RECEIVER, _feeReceiver);
    }

    /// @notice Removes addresses from fee receiver role. Can only be called by an admin.
    /// @param _feeReceiver Array of addresses to remove from fee receiver role.
    function removeFeeReceiver(address[] calldata _feeReceiver) external {
        _checkAdmin(msg.sender);
        _removeRoles(FEE_RECEIVER, _feeReceiver);
    }

    /// @notice Wrapper function to check if an address is a fee receiver.
    /// @param _receiver The address to check.
    /// @return bool True if address is a fee receiver, false otherwise.
    function isFeeReceiver(address _receiver) external view returns (bool) {
        return hasRole(FEE_RECEIVER, _receiver);
    }

    /// @notice Throws if called by any account other than a admin.
    error NotAdmin();

    /// @notice Throws if called by any account other than a default admin.
    error NotDefaultAdmin();

    /// @notice Throws if a token is not whitelisted.
    error TokenNotAccepted();

    /// @notice Throws if a donation recipient is not whitelisted.
    error RecipientNotAccepted();

    /// @notice Throws if the sender is not a whitelisted fee receiver.
    error NotFeeReceiver();
}
