# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a script that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.ts
```
## Vault Token Functions
### symbol() (view)
Returns the symbol of the ERC20 token.

### balanceOf(address account) (view)

Returns the balance of the specified account.

### decimals() (view)

Returns the number of decimals used by the ERC20 token.
### transfer(address recipient, uint256 amount)
Transfers the specified amount of tokens from the caller's account to the recipient's account.

### allowance(address owner, address spender) (view)

Returns the amount of tokens that the spender is allowed to spend on behalf of the owner.
### approve(address spender, uint256 amount)
Sets the allowance for the spender to spend the specified amount of tokens on behalf of the caller.
### transferFrom(address sender, address recipient, uint256 amount)
Transfers the specified amount of tokens from the sender's account to the recipient's account. The caller must have sufficient allowance from the sender.

##Wrapped Position Functions

### token() (view)

Returns the underlying ERC20 token.

### balanceOfUnderlying(address who) (view)

Returns the balance of underlying tokens for the specified account.

### getSharesToUnderlying(uint256 shares) (view)

Converts the specified number of shares to the equivalent amount of underlying tokens.
### deposit(address sender, uint256 amount)
Deposits the specified amount of tokens from the sender's account to the smart contract. Internal ERC20 tokens are minted to the sender.
### withdraw(address sender, uint256 shares, uint256 minUnderlying)
Withdraws the specified number of shares from the sender's account to the specified address. Internal ERC20 tokens are burned.
### withdrawUnderlying(address destination, uint256 amount, uint256 minUnderlying)
Withdraws the specified amount of underlying tokens from the smart contract to the specified address. Shares are calculated based on the underlying tokens received.
### prefundedDeposit(address destination)
Deposits the tokens into the smart contract and mints internal ERC20 tokens to the destination address. Returns the number of shares, used underlying tokens, and the balance of the destination address before the deposit.

### getPricePerFullShare() (view)

Returns the price per full share of the BeefyV6 vault.
### deposit(uint256 amount)
Deposits the specified amount of tokens into the BeefyV6 vault.
### withdraw(uint256 shares)
Withdraws the specified number of shares from the BeefyV6 vault.

### withdrawAll()

Withdraws all shares from the BeefyV6 vault.
### earn()
Executes the earn function of the BeefyV6 vault.

### available() (view)

Returns the amount of tokens available in the BeefyV6 vault.

### want() (view)
Returns the underlying ERC20 token of the BeefyV6 vault.
