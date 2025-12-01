# Sample Hardhat 3 Beta Project (`mocha` and `ethers`)

This project showcases a Hardhat 3 Beta project using `mocha` for tests and the `ethers` library for Ethereum interactions.

To learn more about the Hardhat 3 Beta, please visit the [Getting Started guide](https://hardhat.org/docs/getting-started#getting-started-with-hardhat-3). To share your feedback, join our [Hardhat 3 Beta](https://hardhat.org/hardhat3-beta-telegram-group) Telegram group or [open an issue](https://github.com/NomicFoundation/hardhat/issues/new) in our GitHub issue tracker.

## Project Overview

This example project includes:

- A simple Hardhat configuration file.
- Foundry-compatible Solidity unit tests.
- TypeScript integration tests using `mocha` and ethers.js
- Examples demonstrating how to connect to different types of networks, including locally simulating OP mainnet.

## Usage

### Running Tests

To run all the tests in the project, execute the following command:

```shell
npx hardhat test
```

You can also selectively run the Solidity or `mocha` tests:

```shell
npx hardhat test solidity
npx hardhat test mocha
```

### Ignition deployments

This project now ships with several Ignition modules:

- `ignition/modules/Counter.ts` - basic deployment of the `Counter` contract.
- `ignition/modules/Election.ts` - deploys the on-chain `Election` contract.
- `ignition/modules/ElectionInteractor.ts` - connects to an already deployed `Election` contract and runs a live-election scenario (registers a candidate, voters, votes, and closes the election) using your configured accounts.

Run them against the hardhat-simulated chain with:

```shell
npx hardhat ignition run ElectionModule --network hardhatMainnet
npx hardhat ignition run ElectionModule --network hardhatOp
npx hardhat ignition run ElectionInteractor --network sepoliaFork
```

The Counter module can also be deployed to Sepolia once you set the `SEPOLIA_PRIVATE_KEY` variable:

```shell
npx hardhat ignition run CounterModule --network sepolia
```

### Environment variables & demo keys

Copy `.env.example` to `.env`, then populate the RPC/keystore values. At minimum you should define:

- `SEPOLIA_RPC_URL` – RPC endpoint for Sepolia.
- `SEPOLIA_PRIVATE_KEY` – funded account used for Sepolia tests.
- `ETHERSCAN_API_KEY` – used by the Hardhat `verify` task (optional).

For the forked flows we rely on additional demo accounts. Generate fresh values with:

```shell
bash ./scripts/generate-demo-keys.sh
```

That script emits four random `0x` private keys and rewrites the corresponding `DEMO_ACCOUNT_*_PRIVATE_KEY` entries in `.env`. The Hardhat config (`sepoliaFork` network) reads those variables automatically so Ignition can impersonate multiple users during the ElectionInteractor run.
