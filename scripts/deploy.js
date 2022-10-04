// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {

  const MetaverserItems = await hre.ethers.getContractFactory("MetaverserItems");
  const metaverserItems = await MetaverserItems.deploy();

  await metaverserItems.deployed();

  console.log(
    `MetaverserItems deployed to ${metaverserItems.address}`
  );

  const MarketplaceAssets = await hre.ethers.getContractFactory("MarketplaceAssets");
  const marketplaceAssets = await MarketplaceAssets.deploy(process.env.MTVTToken, metaverserItems.address);

  await marketplaceAssets.deployed();

  console.log(
    `MarketplaceAssets deployed to ${marketplaceAssets.address}`
  );

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
