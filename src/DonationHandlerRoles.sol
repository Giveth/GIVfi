// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {AccessControlUpgradeable as AccessControl} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract DonationHandlerRoles is AccessControl {
    bytes32 public constant ACCEPTED_TOKEN = keccak256("ACCEPTED_TOKEN");
    bytes32 public constant DONATION_RECIPIENT =
        keccak256("DONATION_RECIPIENT");
    bytes32 public constant FEE_RECEIVER = keccak256("FEE_RECEIVER");
    bytes32 public constant ADMIN = keccak256("ADMIN");

    function __DonationHandlerRoles_init(
        address[] calldata _acceptedToken,
        address[] calldata _donationReceiver,
        address[] calldata _feeReceiver,
        address[] calldata _admins
    ) internal onlyInitializing {
        __AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

        _setRoleAdmin(ACCEPTED_TOKEN, ADMIN);
        _setRoleAdmin(DONATION_RECIPIENT, ADMIN);
        _setRoleAdmin(FEE_RECEIVER, ADMIN);

        _addRoles(ACCEPTED_TOKEN, _acceptedToken);
        _addRoles(DONATION_RECIPIENT, _donationReceiver);
        _addRoles(FEE_RECEIVER, _feeReceiver);
        _addRoles(ADMIN, _admins);
    }

    function _addRoles(bytes32 _role, address[] calldata _addresses) internal {
        uint256 length = _addresses.length;
        for (uint256 i = 0; i < length; ) {
            _setupRole(_role, _addresses[i]);
            unchecked {
                i++;
            }
        }
    }

    function _removeRoles(bytes32 _role, address[] calldata _addresses)
        internal
    {
        uint256 length = _addresses.length;
        for (uint256 i = 0; i < length; ) {
            revokeRole(_role, _addresses[i]);
            unchecked {
                i++;
            }
        }
    }

    function _checkAdmin(address _address) internal view {
        if (!hasRole(ADMIN, _address)) revert NotAdmin();
    }

    function addAdmin(address[] calldata _admins) external {
        _checkAdmin(msg.sender);
        _addRoles(ADMIN, _admins);
    }

    function removeAdmin(address[] calldata _admins) external {
        if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) revert NotDefaultAdmin();
        _removeRoles(ADMIN, _admins);
    }

    function revokeAdmin() external {
        _checkAdmin(msg.sender);
        _revokeRole(ADMIN, msg.sender);
    }

    function isAdmin(address _account) external view returns (bool) {
        return hasRole(ADMIN, _account);
    }

    function _checkToken(address _token) internal view {
        if (!hasRole(ACCEPTED_TOKEN, _token)) revert TokenNotAccepted();
    }

    function addToken(address[] calldata _token) external {
        _checkAdmin(msg.sender);
        _addRoles(ACCEPTED_TOKEN, _token);
    }

    function removeToken(address[] calldata _token) external {
        _checkAdmin(msg.sender);
        _removeRoles(ACCEPTED_TOKEN, _token);
    }

    function isTokenAccepted(address _token) external view returns (bool) {
        return hasRole(ACCEPTED_TOKEN, _token);
    }

    function _checkDonationRecipient(address _recipient) internal view {
        if (!hasRole(DONATION_RECIPIENT, _recipient))
            revert RecipientNotAccepted();
    }

    function addDonationRecipient(address[] calldata _recipients) external {
        _checkAdmin(msg.sender);
        _addRoles(DONATION_RECIPIENT, _recipients);
    }

    function removeDonationRecipient(address[] calldata _recipients) external {
        _checkAdmin(msg.sender);
        _removeRoles(DONATION_RECIPIENT, _recipients);
    }

    function isDonationRecipient(address _recipient)
        external
        view
        returns (bool)
    {
        return hasRole(DONATION_RECIPIENT, _recipient);
    }

    function _checkFeeReceiver(address _receiver) internal view {
        if (!hasRole(FEE_RECEIVER, _receiver)) revert NotFeeReceiver();
    }

    function addFeeReceiver(address[] calldata _feeReceiver) external {
        _checkAdmin(msg.sender);
        _addRoles(FEE_RECEIVER, _feeReceiver);
    }

    function removeFeeReceiver(address[] calldata _feeReceiver) external {
        _checkAdmin(msg.sender);
        _removeRoles(FEE_RECEIVER, _feeReceiver);
    }

    function isFeeReceiver(address _receiver) external view returns (bool) {
        return hasRole(FEE_RECEIVER, _receiver);
    }

    error NotAdmin();
    error NotDefaultAdmin();
    error TokenNotAccepted();
    error RecipientNotAccepted();
    error NotFeeReceiver();
}
