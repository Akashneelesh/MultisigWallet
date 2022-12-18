const HDWalletProvider = require("@truffle/hdwallet-provider");
require("dotenv").config();
const {MNEMONIC,API_KEY} = process.env;

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*", // Match any network id
      gas: 5000000
    },
    goerli: {
      networkCheckTimeout: 10000,
      provider: () => {
        return new HDWalletProvider(process.env.MNEMONIC, `wss://eth-goerli.g.alchemy.com/v2/${process.env.API_KEY}`)
      },
      network_id:5,
    },
  },
  compilers: {
    solc: {
      version: "0.8.9",
      settings: {
        optimizer: {
          enabled: true, // Default: false
          runs: 200      // Default: 200
        },
      }
    }
  }
};
