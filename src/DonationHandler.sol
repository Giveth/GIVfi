// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC20Upgradeable as IERC20} from "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import {SafeERC20Upgradeable as SafeERC20} from "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import {ReentrancyGuardUpgradeable as ReentrancyGuard} from "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "./DonationHandlerRoles.sol";

contract DonationHandler is DonationHandlerRoles, ReentrancyGuard {
    using SafeERC20 for IERC20;
    // 1e18 represents 100%, 1e16 represents 1%
    uint256 public constant HUNDRED = 1e18;
    uint256 public minFee;

    // user => token => amount
    mapping(address => mapping(address => uint256)) public balances;

    function initialize(
        address[] calldata _acceptedToken,
        address[] calldata _donationReceiver,
        address[] calldata _feeReceiver,
        address[] calldata _admins
    ) public initializer {
        __DonationHandlerRoles_init(
            _acceptedToken,
            _donationReceiver,
            _feeReceiver,
            _admins
        );
    }

    function donateWithFee(
        address _token,
        address _recipient,
        uint256 _amount,
        uint256 _fee
    ) external nonReentrant {
        if (_fee > HUNDRED) revert FeeTooHigh();
        if (_fee < minFee) revert FeeTooLow();

        _validateDonation(_token, _recipient);
        _transfer(_token, _amount);

        if (_fee == 0) {
            _registerDonation(_token, _recipient, _amount);
        } else if (_fee == HUNDRED) {
            _registerFee(_token, _amount);
        } else {
            uint256 feeAmount = (_amount * _fee) / HUNDRED;
            uint256 donationAmount = _amount - feeAmount;

            _registerDonation(_token, _recipient, donationAmount);
            _registerFee(_token, feeAmount);
        }
    }

    function _registerFee(address _token, uint256 _amount) internal {
        balances[address(this)][_token] += _amount;
        emit FeeRegistered(_token, _amount);
    }

    function _registerDonation(
        address _token,
        address _recipient,
        uint256 _amount
    ) internal {
        balances[_recipient][_token] += _amount;
        emit DonationRegistered(_token, _recipient, _amount);
    }

    function _validateDonation(address _token, address _recipient)
        internal
        view
    {
        _checkToken(_token);
        _checkDonationRecipient(_recipient);
    }

    function _transfer(address _token, uint256 _amount) internal {
        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
    }

    function withdraw(address _token, uint256 _amount) external nonReentrant {
        _withdraw(_token, msg.sender, msg.sender, _amount);
    }

    function withdrawAll(address[] calldata _token) external nonReentrant {
        _withdrawAll(_token, msg.sender, msg.sender);
    }

    function distribute(address[] calldata _token, address _to)
        external
        nonReentrant
    {
        // TODO: maybe restrict to admins
        _withdrawAll(_token, _to, _to);
    }

    function distributeMany(address[] calldata _token, address[] calldata _to)
        external
        nonReentrant
    {
        // TODO: maybe restrict to admins
        uint256 length = _to.length;
        for (uint256 i = 0; i < length; i++) {
            _withdrawAll(_token, _to[i], _to[i]);
        }
    }

    function withdrawFee(address _token) external nonReentrant {
        address[] memory token = new address[](1);
        token[0] = _token;
        _checkFeeReceiver(msg.sender);
        _withdrawAll(token, address(this), msg.sender);
    }

    function withdrawFeeMany(address[] calldata _token) external nonReentrant {
        _checkFeeReceiver(msg.sender);
        _withdrawAll(_token, address(this), msg.sender);
    }

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

    function _withdraw(
        address _token,
        address _from,
        address _to,
        uint256 _amount
    ) internal {
        if (_amount > balances[_from][_token]) revert InsufficientBalance();

        balances[_from][_token] -= _amount;
        IERC20(_token).safeTransfer(_to, _amount);

        emit Withdraw(_token, _from, _to, _amount);
    }

    function balanceOf(address _token, address _user)
        external
        view
        returns (uint256)
    {
        return balances[_user][_token];
    }

    function balancesOf(address[] calldata _token, address _user)
        external
        view
        returns (uint256[] memory)
    {
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

    function setMinFee(uint256 _min_fee) external {
        _checkAdmin(msg.sender);
        if (_min_fee > HUNDRED) revert FeeTooHigh();
        minFee = _min_fee;
        emit MinFeeSet(_min_fee);
    }

    error FeeTooHigh();
    error FeeTooLow();
    error InsufficientBalance();

    event FeeRegistered(address indexed token, uint256 amount);
    event DonationRegistered(
        address indexed token,
        address indexed recipient,
        uint256 amount
    );
    event Withdraw(
        address indexed token,
        address indexed from,
        address indexed to,
        uint256 amount
    );
    event MinFeeSet(uint256 min_fee);
}
