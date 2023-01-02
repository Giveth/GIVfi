// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol";

contract Vault is ERC4626Upgradeable {
    function initialize(string memory _name, string memory _symbol, IERC20Upgradeable _underlying) public initializer {
        __ERC20_init(_name, _symbol);
        __ERC4626_init(_underlying);
    }
}
