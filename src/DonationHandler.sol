// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IERC20Upgradeable as IERC20} from "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import {SafeERC20Upgradeable as SafeERC20} from "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import {ReentrancyGuardUpgradeable as ReentrancyGuard} from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "./DonationHandlerRoles.sol";
import "./gitcoin/IVotingStrategy.sol";

/// @title DonationHandler
/// @author @Kurt for Giveth
/// @notice This contract is used to handle donations
/// This contract is build to use with proxies.
///
/// The user can donate whitelisted token to whitelisted recipients by calling the donate function.
/// A donation fee can be set by the user. The fee is paid in addition to the donation amount.
/// The donation fee is the amount the donor pays to the fee receiver (protocol)
/// The donation fee can be set by the user and is limited by the minFee.
/// The min fee is set by default to 0 and can be changed by the protocol admins.
/// The max fee is set by default to 1e18 and can't be changed.
///
/// The user can withdraw the donation of a single token by calling the withdraw function.
/// The user can withdraw all donations of a list of token by calling the withdrawMany function.
///
/// The fee receiver can withdraw the donation fee by calling the withdrawFee function.
/// The fee receiver can withdraw the donation fee of a list of token by calling the withdrawFeeMany function.
///
/// Users can distribute the funds of a list of token in behalf of a recipient by calling the distribute function.
/// Users can distribute the funds of a list of token in behalf of a list of recipients by calling the distributeMany function.
///
/// The donation balance of one token can be checked by calling the balanceOf function.
/// The donation balance of multiple token can be checked by calling the balancesOf function.
contract DonationHandler is
    IVotingStrategy,
    DonationHandlerRoles,
    ReentrancyGuard
{
    using SafeERC20 for IERC20;

    /// @notice 1e18 represents 100%, 1e16 represents 1%
    uint256 public constant HUNDRED = 1e18;

    /// @notice Minimum donation fee. 0 by default
    uint256 public minFee;

    bool public isTokenWhitelistActive;
    bool public isRecipientWhitelistActive;

    /// @notice mapping: user => token => amount
    mapping(address => mapping(address => uint256)) public balances;

    /// @notice Initialize the contract.
    /// @param _acceptedToken Array of accepted tokens
    /// @param _donationReceiver Array of donation receivers
    /// @param _feeReceiver Array of fee receivers
    /// @param _admins Array of admins
    function initialize(
        address[] calldata _acceptedToken,
        address[] calldata _donationReceiver,
        address[] calldata _feeReceiver,
        address[] calldata _admins,
        uint256 _minFee
    ) public initializer {
        __DonationHandlerRoles_init(
            _acceptedToken,
            _donationReceiver,
            _feeReceiver,
            _admins
        );
        __ReentrancyGuard_init();

        if (_acceptedToken.length > 0) {
            isTokenWhitelistActive = true;
        }
        if (_donationReceiver.length > 0) {
            isRecipientWhitelistActive = true;
        }

        if(_minFee > 0) {
            _setMinFee(_minFee);
        }
    }

    function vote(
        bytes[] calldata encodedVotes,
        address voterAddress
    ) external payable override nonReentrant isRoundContract {
        /// @dev iterate over multiple donations and transfer funds
        uint256 length = encodedVotes.length;
        uint256 msgValue = 0;

        for (uint256 i = 0; i < length; ) {
            (address _token, uint256 _amount, address _grantAddress) = abi
                .decode(encodedVotes[i], (address, uint256, address));

            if (isTokenWhitelistActive) _checkToken(_token);
            if (isRecipientWhitelistActive) {
                _checkDonationRecipient(_grantAddress);
            }

            if (_token != NATIVE) {
                _transfer(voterAddress, _token, _amount);
            } else {
                msgValue += _amount;
            }

            if (minFee > 0) {
                uint256 fee = (_amount * minFee) / HUNDRED;

                _registerDonation(_token, _grantAddress, _amount - fee);
                _registerFee(_token, fee);
            } else {
                _registerDonation(_token, _grantAddress, _amount);
            }

            unchecked {
                i++;
            }
        }

        if (msgValue > msg.value) {
            revert InvalidAmount();
        }
    }

    /// @notice Internal function. Registers a donated fee by adding it to the balance of the contract and emitting the FeeRegistered event.
    /// @param _token Address of the token
    /// @param _amount Amount of tokens
    function _registerFee(address _token, uint256 _amount) internal {
        balances[address(this)][_token] += _amount;
        emit FeeRegistered(_token, msg.sender, _amount);
    }

    /// @notice Internal function. Registers a donation by adding it to the balance of the recipient and emitting the DonationRegistered event.
    /// @param _token Address of the token
    /// @param _recipient Address of the recipient
    /// @param _amount Amount of tokens
    function _registerDonation(
        address _token,
        address _recipient,
        uint256 _amount
    ) internal {
        balances[_recipient][_token] += _amount;
        emit DonationRegistered(_token, msg.sender, _recipient, _amount);
    }

    /// @notice Internal function. Transfers tokens from the sender to the contract.
    /// @param _token Address of the token
    /// @param _amount Amount of tokens
    function _transfer(
        address _from,
        address _token,
        uint256 _amount
    ) internal {
        IERC20(_token).safeTransferFrom(_from, address(this), _amount);
    }

    /// @notice Withdraw tokens from the contract to msg.sender.
    /// @param _token Address of the token
    /// @param _amount Amount of tokens
    function withdraw(address _token, uint256 _amount) external nonReentrant {
        if (_amount == 0) revert InvalidAmount();
        _withdraw(_token, msg.sender, msg.sender, _amount);
    }

    /// @notice Withdraw full amount of token arrays token from the contract to msg.sender.
    /// @param _token Address array of the token
    function withdrawMany(address[] calldata _token) external nonReentrant {
        _withdrawAll(_token, msg.sender, msg.sender);
    }

    /// @notice Distributes full amount of token arrays token from the contract to a recipient.
    /// @param _token Address array of the token
    /// @param _to Address of the recipient
    function distribute(
        address[] calldata _token,
        address _to
    ) external nonReentrant {
        // TODO: maybe restrict to admins
        _withdrawAll(_token, _to, _to);
    }

    /// @notice Distributes full amount of token arrays token from the contract to an array of recipients.
    /// @param _token Address array of the token
    /// @param _to Address array of the recipients
    function distributeMany(
        address[] calldata _token,
        address[] calldata _to
    ) external nonReentrant {
        // TODO: maybe restrict to admins
        uint256 length = _to.length;
        for (uint256 i = 0; i < length; ) {
            _withdrawAll(_token, _to[i], _to[i]);
            unchecked {
                i++;
            }
        }
    }

    /// @notice Withdraw donated fees from the contract to a fee receiver. Can only be called by a fee receiver.
    /// @param _token Address of the token
    function withdrawFee(address _token) external nonReentrant {
        address[] memory token = new address[](1);
        token[0] = _token;
        _checkFeeReceiver(msg.sender);
        _withdrawAll(token, address(this), msg.sender);
    }

    /// @notice Withdraw donated fees from the contract to a fee receiver. Can only be called by a fee receiver.
    /// @param _token Address array of the token
    function withdrawFeeMany(address[] calldata _token) external nonReentrant {
        _checkFeeReceiver(msg.sender);
        _withdrawAll(_token, address(this), msg.sender);
    }

    /// @notice Internal function. Withdraw all donated funds from a list of token from the contract to the recipient.
    /// @param _token Address array of the token to withdraw
    /// @param _from Address of the spender
    /// @param _to Address of the recipient
    function _withdrawAll(
        address[] memory _token,
        address _from,
        address _to
    ) internal {
        uint256 length = _token.length;

        for (uint256 i = 0; i < length; ) {
            uint256 amount = balances[_from][_token[i]];

            if (amount > 0) {
                _withdraw(_token[i], _from, _to, amount);
            }

            unchecked {
                i++;
            }
        }
    }

    /// @notice Internal function. Withdraw donated funds from a token from the contract to the recipient. Emits Withdraw event.
    /// @param _token Address of the token to withdraw
    /// @param _from Address of the spender
    /// @param _to Address of the recipient
    /// @param _amount Amount of tokens to withdraw
    function _withdraw(
        address _token,
        address _from,
        address _to,
        uint256 _amount
    ) internal {
        if (_amount > balances[_from][_token]) revert InsufficientBalance();

        balances[_from][_token] -= _amount;
        if (_token == NATIVE) {
            (bool success, ) = payable(_to).call{value: _amount}("");
            if (!success) revert TransferFailed();
        } else {
            IERC20(_token).safeTransfer(_to, _amount);
        }

        emit Withdraw(_token, _from, _to, _amount);
    }

    /// @notice Returns the token balance of a user
    /// @param _token Address of the token
    /// @param _user Address of the user
    /// @return Token balance of the user
    function balanceOf(
        address _token,
        address _user
    ) external view returns (uint256) {
        return balances[_user][_token];
    }

    /// @notice Returns the token balances of a user
    /// @param _token Address array of the token
    /// @param _user Address of the user
    /// @return Uint256 array. Token balances of the user
    function balancesOf(
        address[] calldata _token,
        address _user
    ) external view returns (uint256[] memory) {
        uint256 length = _token.length;
        uint256[] memory result = new uint256[](length);

        for (uint256 i = 0; i < length; ) {
            result[i] = balances[_user][_token[i]];
            unchecked {
                i++;
            }
        }
        return result;
    }

    /// @notice Set minimum donation fee. Can only be called by an Admin. Emits MinFeeSet event.
    /// @param _minFee Minimum donation fee
    function setMinFee(uint256 _minFee) external {
        _checkAdmin(msg.sender);
        _setMinFee(_minFee);
    }

    function _setMinFee(uint256 _minFee) internal {
        if (_minFee > HUNDRED) revert FeeTooHigh();
        minFee = _minFee;
        emit MinFeeSet(_minFee);
    }

    function setIsTokenWhitelistActive(bool _isTokenWhitelistActive) external {
        _checkAdmin(msg.sender);
        isTokenWhitelistActive = _isTokenWhitelistActive;
        emit IsTokenWhitelistActiveSet(_isTokenWhitelistActive);
    }

    function setIsRecipientWhitelistActive(
        bool _isRecipientWhitelistActive
    ) external {
        _checkAdmin(msg.sender);
        isRecipientWhitelistActive = _isRecipientWhitelistActive;
        emit IsRecipientWhitelistActiveSet(_isRecipientWhitelistActive);
    }

    /// @notice Throws if passed fee is above 100%.
    error FeeTooHigh();

    /// @notice Throws if passed fee is below minFee.
    error FeeTooLow();

    /// @notice Throws if the withdrawal amount is too high.
    error InsufficientBalance();

    /// @notice Throws if amount is zero or does not match the msg.value
    error InvalidAmount();

    /// @notice Throws if the native currency transfer failed
    error TransferFailed();

    /// @notice Emitted when a fee is registered
    /// @param token The token address
    /// @param from The address of the sender
    /// @param amount The amount of tokens
    event FeeRegistered(
        address indexed token,
        address indexed from,
        uint256 amount
    );

    /// @notice Emitted when a donation is registered
    /// @param token The token address
    /// @param from The address of the sender
    /// @param recipient The address of the recipient
    /// @param amount The amount of tokens
    event DonationRegistered(
        address indexed token,
        address indexed from,
        address indexed recipient,
        uint256 amount
    );

    /// @notice Emitted when a withdrawal is made
    /// @param token The token address
    /// @param from The address of the sender
    /// @param to The address of the recipient
    /// @param amount The amount of tokens
    event Withdraw(
        address indexed token,
        address indexed from,
        address indexed to,
        uint256 amount
    );

    /// @notice Emitted when the minimum fee is set
    /// @param minFee The minimum fee
    event MinFeeSet(uint256 minFee);

    /// @notice Emitted when the token whitelist is set to active or inactive
    /// @param isTokenWhitelistActive The token whitelist status
    event IsTokenWhitelistActiveSet(bool isTokenWhitelistActive);

    /// @notice Emitted when the recipient whitelist is set to active or inactive
    /// @param isRecipientWhitelistActive The recipient whitelist status
    event IsRecipientWhitelistActiveSet(bool isRecipientWhitelistActive);
}
