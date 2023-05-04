// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./element-fi/interfaces/IERC20.sol";

interface IBeefyV6 is IERC20 {
    function getPricePerFullShare() external view returns (uint256);
    function deposit(uint256 _amount) external;
    function withdraw(uint256 _shares) external;
    function withdrawAll() external;
    function earn() external;
    function available() external view returns (uint256);
    function want() external view returns (IERC20);
}