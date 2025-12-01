import "dotenv/config";

import hardhatToolboxMochaEthersPlugin from "@nomicfoundation/hardhat-toolbox-mocha-ethers";
import { configVariable, defineConfig } from "hardhat/config";

export default defineConfig({
  plugins: [hardhatToolboxMochaEthersPlugin],
  solidity: {
    profiles: {
      default: {
        version: "0.8.28",
      },
      production: {
        version: "0.8.28",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    },
  },
  networks: {
    hardhatMainnet: {
      type: "edr-simulated",
      chainType: "l1",
    },
    hardhatOp: {
      type: "edr-simulated",
      chainType: "op",
    },
    sepolia: {
      type: "http",
      chainType: "l1",
      url: configVariable("SEPOLIA_RPC_URL"),
      accounts: [configVariable("SEPOLIA_PRIVATE_KEY")],
    },
    sepoliaFork: {
      type: "edr-simulated",
      chainType: "l1",
      accounts: [
        {
          privateKey: configVariable("SEPOLIA_PRIVATE_KEY"),
          balance: "100000000000000000000000",
        },
        {
          privateKey: configVariable("DEMO_ACCOUNT_1_PRIVATE_KEY"),
          balance: "100000000000000000000000",
        },
        {
          privateKey: configVariable("DEMO_ACCOUNT_2_PRIVATE_KEY"),
          balance: "100000000000000000000000",
        },
        {
          privateKey: configVariable("DEMO_ACCOUNT_3_PRIVATE_KEY"),
          balance: "100000000000000000000000",
        },
        {
          privateKey: configVariable("DEMO_ACCOUNT_4_PRIVATE_KEY"),
          balance: "100000000000000000000000",
        },
      ],
      forking: {
        url: configVariable("SEPOLIA_RPC_URL"),
        blockNumber: 9725259,
      },
    },
  },
  verify: {
    etherscan: {
      apiKey: configVariable("ETHERSCAN_API_KEY"),
    },
  },
});
