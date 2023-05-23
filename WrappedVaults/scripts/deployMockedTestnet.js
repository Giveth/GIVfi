const { ethers, upgrades } = require("hardhat");

async function deploy() {
  const [deployer] = await ethers.getSigners();
  const deployerAddress = deployer.address;
  // deploy erc20mock
  const ERC20Mock = await ethers.getContractFactory("ERC20Mock");
  const erc20Mock = await ERC20Mock.deploy("Mocked USDC", "mockUSDC");
  await erc20Mock.deployed();

  // deploy beefy vault mock
  const BeefyVaultMock = await ethers.getContractFactory(
    "BeefyV6MockWithAutoInterest",
  );
  const beefyVaultMock = await BeefyVaultMock.deploy(erc20Mock.address);
  await beefyVaultMock.deployed();

  // Get the addresses of other contracts and accounts
  const beefyV6VaultAddress = beefyVaultMock.address;
  const underlyingTokenAddress = erc20Mock.address;
  const vaultName = "GIVfi USDC";
  const vaultSymbol = "GIVUSDC";
  const governanceAddress = "0x1cA656EB3B457a0e34C11B2ECf7e8159BeCe4cB6"; // Replace with the actual address
  const pauserAddress = "0x1cA656EB3B457a0e34C11B2ECf7e8159BeCe4cB6"; // Replace with the actual address
  const fee = (1e17).toString(); // 10% fee (1 eth == 100% => 0.1 eth == 10%)
  const feeRecipientAddress = "0x1cA656EB3B457a0e34C11B2ECf7e8159BeCe4cB6"; // Replace with the actual address

  // Deploy the GIVfiWrappedBeefyV6Vault contract
  const GIVfiWrappedBeefyV6Vault = await ethers.getContractFactory(
    "GIVfiWrappedBeefyV6VaultUpgradeable",
  );
  const givVault = await upgrades.deployProxy(
    GIVfiWrappedBeefyV6Vault,
    [
      beefyV6VaultAddress,
      underlyingTokenAddress,
      vaultName,
      vaultSymbol,
      governanceAddress,
      pauserAddress,
      fee,
      feeRecipientAddress,
    ],
    {
      initializer: "initialize",
      verifySourceCode: true,
    },
  );

  // Wait for the contract to be deployed and get the deployed instance
  await givVault.deployed();

  // Initialize the GIVfiWrappedBeefyV6Vault contract
  // await givVault.initialize(
  //   beefyV6VaultAddress,
  //   underlyingTokenAddress,
  //   vaultName,
  //   vaultSymbol,
  //   governanceAddress,
  //   pauserAddress,
  //   fee,
  //   feeRecipientAddress,
  // );

  console.log("Contract deployed and initialized successfully!");
  // log all addresses
  console.log("GivVault address:", givVault.address);
  console.log("BeefyVaultMock address:", beefyVaultMock.address);
  console.log("ERC20Mock address:", erc20Mock.address);
  console.log("Deployer address:", deployerAddress);
}

deploy()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
