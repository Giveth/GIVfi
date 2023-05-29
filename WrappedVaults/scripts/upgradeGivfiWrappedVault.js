const { ethers, upgrades } = require("hardhat");

async function main() {
  // upgrade deployed beefy wraped vault

  const [deployer] = await ethers.getSigners();

  const proxy = "0x799E7D9776c4A0392F6829DCB6BDc593d598F7AA";

  const GIVfiWrappedBeefyV6Vault = await ethers.getContractFactory(
    "GIVfiWrappedBeefyV6VaultUpgradeable",
  );

  await upgrades.validateUpgrade(proxy, GIVfiWrappedBeefyV6Vault);

  const givVault = await upgrades.upgradeProxy(proxy, GIVfiWrappedBeefyV6Vault);

  console.log("GIVfiWrappedBeefyV6Vault upgraded to:", givVault.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
