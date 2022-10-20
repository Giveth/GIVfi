# Table of Contents
- [Table of Contents](#table-of-contents)
- [GIVfi-donation-handler](#givfi-donation-handler)
  - [Requirements](#requirements)
    - [Foundry](#foundry)
  - [Quickstart](#quickstart)
  - [Run Tests](#run-tests)
  - [Deploying to a network](#deploying-to-a-network)
    - [Initialization Parameter](#initialization-parameter)
    - [Deploying](#deploying)
  - [Security](#security)

# GIVfi-donation-handler
The DonationHandler can be used to transfer whitelisted assets to whitelisted addresses. Furthermore, the donator can specify a fee that the protocol or the fee receiver will receive. All assets are hold by the DonationHandler contract and can be withdrawn later by the recipients.

## Requirements
### Foundry
Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.
[Learn more.](https://github.com/foundry-rs/foundry)

## Quickstart
```
git clone https://github.com/Giveth/GIVfi-donation-handler
cd GIVfi-donation-handler
make # This installs the project's dependencies.
make test
```

## Run Tests
`make test`
or
`forge test`


## Deploying to a network

You'll need to add the following variables to a .env file:

- `GOERLI_RPC_URL`: A URL to connect to the Goerli Testnet.
- `GNOSIS_RPC_URL`: A URL to connect to the Gnosis Chain.
- `PRIVATE_KEY`: A private key from your wallet.
- Optional `ETHERSCAN_API_KEY`: If you want to verify on etherscan

### Initialization Parameter

Before deploying to one of the networks, please adjust the DonationHandler initialization parameter in `script/Config.sol`. You need to specify the whitelisted addresses for the accepted token, donation recipients, fee receivers and admins. You can set the parameters for each network separately in the corresponding functions (e.g. `getGnosisEthConfig()`).

### Deploying
- `make deploy-gnosis`
  Deploys the DonationHandler, a ProxyAdmin and a TransparentUpgradeableProxy to gnosis chain.

- `make deploy-goerli`
  Deploys the DonationHandler, a ProxyAdmin and a TransparentUpgradeableProxy to goerli testnet.

- `make deploy-anvil`
Deploys the DonationHandler, a ProxyAdmin and a TransparentUpgradeableProxy to your local anvil chain. Please run `make anvil` before deploying.

## Security
To use slither, you'll first need to install [slither](https://github.com/crytic/slither#how-to-install).

Then, you can run:

`make slither`