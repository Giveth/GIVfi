// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IDonationHandlerRoles {
    function addAdmin(address[] calldata _admins) external;

    function removeAdmin(address[] calldata _admins) external;

    function revokeAdmin() external;

    function isAdmin(address _account) external view returns (bool);

    function addToken(address[] calldata _token) external;

    function removeToken(address[] calldata _token) external;

    function isTokenAccepted(address _token) external view returns (bool);

    function addDonationRecipient(address[] calldata _recipients) external;

    function removeDonationRecipient(address[] calldata _recipients) external;

    function isDonationRecipient(address _recipient) external view returns (bool);

    function addFeeReceiver(address[] calldata _feeReceiver) external;

    function removeFeeReceiver(address[] calldata _feeReceiver) external;

    function isFeeReceiver(address _receiver) external view returns (bool);
}
