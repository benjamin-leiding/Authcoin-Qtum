#Introduction#

Solidity smart contracts for Authcoin.

## Development Environment ##

Truffle framework is used to write and test Solidity smart contracts. To set up the development environment we need to have _Node_ and _npm_ installed. After that we need to install the _TestRPC_ and _Truffle_:

```
npm install -g ethereumjs-testrpc
npm install -g truffle
```

## Directory Structure ##

The project directory has the following structure:

* **/contracts:** - Contains the Solidity source files for smart contracts. There is an important contract in here called Migrations.sol. Be sure **not to delete** this file!
* **/migrations:** - Truffle uses a migration system to handle smart contract deployments. A migration is an additional special smart contract that keeps track of changes.
* **/test:** - Contains tests for smart contracts. All unit test should be written in Solidity.
* **truffle.js:** - Truffle's configuration file

## Compile Smart Contracts ##

Execute `truffle compile` command

## Run Tests ##

1. Run `testrpc`
2. Run `truffle test`
