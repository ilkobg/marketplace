const { ethers } = require('hardhat');
const hre = require('hardhat');

async function main(_privateKey) {
    const wallet = new ethers.Wallet(_privateKey, ethers.provider);
    console.log("Deploying contracts with the account:", wallet.address);

    const NFT = await hre.ethers.getContractFactory("NFT");
    const NFTContract = await NFT.connect(wallet).deploy();

    const Marketplace = await hre.ethers.getContractFactory("Marketplace");
    const MarketplaceContract = await Marketplace.connect(wallet).deploy();

    await MarketplaceContract.deployed();
    await NFTContract.deployed();

    console.log("MarketplaceContract deployed to:", MarketplaceContract.address);
    console.log("NFTContract deployed to:", NFTContract.address);
}

module.exports = {
  main: main
};
