const { ethers, upgrades } = require("hardhat");

async function deploy() {
  // Deploy the GIVfiWrappedBeefyV6Vault contract
  const GIVfiWrappedBeefyV6Vault = await ethers.getContractFactory(
    "GIVfiWrappedBeefyV6VaultUpgradeable",
  );
  const givVault = await upgrades.deployProxy(GIVfiWrappedBeefyV6Vault);

  // Wait for the contract to be deployed and get the deployed instance
  await givVault.deployed();

  // Get the addresses of other contracts and accounts
  const beefyV6VaultAddress = "0xE7db4eA58560D4678DF204165D1f50d18185BC89"; // optimism usdc vault
  const underlyingTokenAddress = "0x7F5c764cBc14f9669B88837ca1490cCa17c31607"; // optimism usdc
  const vaultName = "GIVfi USDC";
  const vaultSymbol = "GIVUSDC";
  const governanceAddress = "0x1cA656EB3B457a0e34C11B2ECf7e8159BeCe4cB6"; // Replace with the actual address
  const pauserAddress = "0x1cA656EB3B457a0e34C11B2ECf7e8159BeCe4cB6"; // Replace with the actual address
  const fee = 1e17.toString(); // 10% fee (1 eth == 100% => 0.1 eth == 10%)
  const feeRecipientAddress = "0x1cA656EB3B457a0e34C11B2ECf7e8159BeCe4cB6"; // Replace with the actual address

  // Initialize the GIVfiWrappedBeefyV6Vault contract
  await givVault.initialize(
    beefyV6VaultAddress,
    underlyingTokenAddress,
    vaultName,
    vaultSymbol,
    governanceAddress,
    pauserAddress,
    fee,
    feeRecipientAddress,
  );

  console.log("Contract deployed and initialized successfully!");
  console.log("Contract address:", givVault.address);
}

deploy()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
