import * as dotenv from "dotenv";
import "@nomiclabs/hardhat-ethers";
import "@openzeppelin/hardhat-upgrades";
import "@nomiclabs/hardhat-etherscan";

dotenv.config();

const { API_KEY, PRIVATE_KEY, POLYSCAN_API_KEY } = process.env;

module.exports = {
  solidity: {
    version: "0.8.12",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  defaultNetwork: "mumbai",
  networks: {
    mumbai: {
      url: `https://polygon-mumbai.g.alchemy.com/v2/${API_KEY}`,
      accounts: [`0x${PRIVATE_KEY}`],
      gasLimit: 30000000,
      gasPrice: 31285415750,
      saveDeployments: true,
    },
  },
  etherscan: {
    apiKey: POLYSCAN_API_KEY,
  },
};
