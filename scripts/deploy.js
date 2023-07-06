const hre = require('hardhat');

async function main() {
  const NFT = await hre.ethers.getContractFactory("NFT");
  const NFTContract = await NFT.deploy();

  const Marketplace = await hre.ethers.getContractFactory("Marketplace");
  const MarketplaceContract = await Marketplace.deploy();

  await MarketplaceContract.deployed();
  await NFTContract.deployed();

  console.log("MarketplaceContract deployed to:", MarketplaceContract.address);
  console.log("NFTContract deployed to:", NFTContract.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

module.exports = {
  main: main
};
