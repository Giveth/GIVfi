// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.17;

import "./BeefyV6AssetProxyUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract GIVfiWrappedBeefyV6VaultUpgradeable is Initializable, BeefyV6AssetProxyUpgradeable {
    uint256 public constant FEE_DENOMINATOR = 1e18;
    uint256 public fee;
    address public feeRecipient;

    mapping(address => uint256) public balanceSnapshots;

    function initialize(
        address vault_,
        address _token,
        string memory _name,
        string memory _symbol,
        address _governance,
        address _pauser,
        uint256 _fee,
        address _feeRecipient
    ) public initializer {
        __BeefyV6AssetProxyUpgradeable_init(vault_, _token, _name, _symbol, _governance, _pauser);
        fee = _fee;
        feeRecipient = _feeRecipient;
    }

    modifier handleFeeOnInterest(address _destination) {
        uint256 underlyingBalance = _underlying(balanceOf(_destination));
        uint256 balanceSnapshot = balanceSnapshots[_destination];
        uint256 accruedInterest = 0;

        // check if user has accrued interest (deposited amount - underlying balance)
        if (underlyingBalance > balanceSnapshot) {
            accruedInterest = underlyingBalance - balanceSnapshot;

            uint256 feeAmount = (accruedInterest * fee) / FEE_DENOMINATOR;
            uint256 feeInShares = feeAmount / _pricePerShare();

            // mint fee shares to fee recipient
            // burn fee shares from _destination
            if (feeInShares > 0) {
                _mint(feeRecipient, feeInShares);
                _burn(_destination, feeInShares);
                emit FeesPaid(
                    _destination,
                    feeRecipient,
                    feeInShares,
                    feeAmount
                );
            }
        }

        _;
        balanceSnapshots[_destination] = _underlying(balanceOf(_destination));
    }

    function deposit(
        address _destination,
        uint256 _amount
    ) public override(WrappedPositionUpgradeable) returns (uint256) {
        balanceSnapshots[_destination] += _amount;
        return super.deposit(_destination, _amount);
    }

    function _positionWithdraw(
        address _destination,
        uint256 _shares,
        uint256 _minUnderlying,
        uint256 _underlyingPerShare
    ) internal override handleFeeOnInterest(_destination) returns (uint256) {
        uint256 shares = _shares;

        // if shares are greater than balance (because of fee deduction), withdraw all
        if (shares > balanceOf(_destination)) {
            shares = balanceOf(_destination);
        }

        return
            super._positionWithdraw(
                _destination,
                shares,
                _minUnderlying,
                _underlyingPerShare
            );
    }

    function setFee(uint256 _fee) external onlyOwner {
        require(_fee <= FEE_DENOMINATOR, "Fee cannot be greater than 100%");
        fee = _fee;
        emit FeeSet(_fee);
    }

    function setFeeRecipient(address _feeRecipient) external onlyOwner {
        feeRecipient = _feeRecipient;
        emit FeeRecipientSet(_feeRecipient);
    }

    event FeeSet(uint256 fee);
    event FeeRecipientSet(address feeRecipient);
    event FeesPaid(
        address indexed user,
        address indexed recipient,
        uint256 shares,
        uint256 amount
    );
}