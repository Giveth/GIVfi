// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./IDonationHandlerRoles.sol";

interface IDonationHandler is IDonationHandlerRoles {
    /// @notice struct stores recipient and amount of a donation
    struct RecipientInfo {
        address recipient;
        uint256 amount;
    }

    /// @notice struct stores the informations of a donation with multiple receipients
    struct Donation {
        address token;
        uint256 fee;
        RecipientInfo[] recipients;
    }

    /// @notice Initialize the contract.
    /// @param _acceptedToken Array of accepted tokens
    /// @param _donationReceiver Array of donation receivers
    /// @param _feeReceiver Array of fee receivers
    /// @param _admins Array of admins
    function initialize(
        address[] calldata _acceptedToken,
        address[] calldata _donationReceiver,
        address[] calldata _feeReceiver,
        address[] calldata _admins
    ) external;

    /// @notice Donate tokens to a recipient. The fee added to the donation amount.
    /// @param _token Address of the token to donate
    /// @param _recipient Address of the recipient
    /// @param _amount Amount of tokens to donate
    /// @param _fee Fee to be paid to the fee receiver (protocol)
    function donate(address _token, address _recipient, uint256 _amount, uint256 _fee) external payable;

    /// @notice Donate a list of donations.
    /// @param _donations Array of donations. Each donation contains a token, a fee and a list of recipients. Each recipient contains an address and an amount.
    function donateMany(Donation[] memory _donations) external payable;

    /// @notice Withdraw tokens from the contract to msg.sender.
    /// @param _token Address of the token
    /// @param _amount Amount of tokens
    function withdraw(address _token, uint256 _amount) external;

    /// @notice Withdraw full amount of token arrays token from the contract to msg.sender.
    /// @param _token Address array of the token
    function withdrawMany(address[] calldata _token) external;

    /// @notice Distributes full amount of token arrays token from the contract to a recipient.
    /// @param _token Address array of the token
    /// @param _to Address of the recipient
    function distribute(address[] calldata _token, address _to) external;

    /// @notice Distributes full amount of token arrays token from the contract to an array of recipients.
    /// @param _token Address array of the token
    /// @param _to Address array of the recipients
    function distributeMany(address[] calldata _token, address[] calldata _to) external;

    /// @notice Withdraw donated fees from the contract to a fee receiver. Can only be called by a fee receiver.
    /// @param _token Address of the token
    function withdrawFee(address _token) external;

    /// @notice Withdraw donated fees from the contract to a fee receiver. Can only be called by a fee receiver.
    /// @param _token Address array of the token
    function withdrawFeeMany(address[] calldata _token) external;

    /// @notice Returns the token balance of a user
    /// @param _token Address of the token
    /// @param _user Address of the user
    /// @return Token balance of the user
    function balanceOf(address _token, address _user) external view returns (uint256);

    /// @notice Returns the token balances of a user
    /// @param _token Address array of the token
    /// @param _user Address of the user
    /// @return Uint256 array. Token balances of the user
    function balancesOf(address[] calldata _token, address _user) external view returns (uint256[] memory);

    /// @notice Set minimum donation fee. Can only be called by an Admin. Emits MinFeeSet event.
    /// @param _minFee Minimum donation fee
    function setMinFee(uint256 _minFee) external;
}
