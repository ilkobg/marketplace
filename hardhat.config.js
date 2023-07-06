require("@nomicfoundation/hardhat-toolbox");

require('dotenv').config();

const privateKey = process.env.PRIVATE_KEY;
const infuraApiKey = process.env.INFURA_API_KEY;
let etherscanApiKey = process.env.ETHERSCAN_API_KEY;
//etherscanApiKey = etherscanApiKey.toString();
//console.log("etherscan key: " + etherscanApiKey);

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    // Goerli Testnet
    goerli: {
      url: `https://goerli.infura.io/v3/` + infuraApiKey,
      chainId: 5,
      accounts: [privateKey],
    },
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at <https://etherscan.io/>
    apiKey: etherscanApiKey
  }
};

const lazyImport = async (module) => {
  return await import(module);
};

task("deploy-pk", "Deploys contract with pk")
  .addParam("privateKey", "Please provide the private key")
  .setAction(async ({ privateKey }) => {
    const { main } = await lazyImport("./scripts/deploy-pk.js");
    await main(privateKey);
});

task("deploy", "Deploys contract").setAction(async () => {
  const { main } = await lazyImport("./scripts/deploy.js");
  await main();
});
