# Introduction #

Authcoin is an alternative approach to the commonly used public key infrastructures such as central authorities and the PGP web of 
trust. It combines a challenge response-based validation and authentication process for domains, certificates, email accounts and 
public keys with the advantages of a block chain-based storage system. Due to its transparent nature and public availability, it is 
possible to track the whole validation and authentication process history of each entity in the Authcoin system which makes it much 
more difficult to introduce sybil nodes and prevent such nodes from getting detected by genuine users.

This repository contains Solidity smart contracts for Authcoin protocol. Current implementation contains the following functionality:

* [Posting an entity identity record (EIR) to the blockchain](#eir_post)
* [Querying EIR by id](#eir_post)
* [Revoking EIR](#eir_revoke)
* [Customized EIR format](#eir_custom)
* [Posting a challenge record (CR) to the blockchain](#cr_post) 
* [Querying CR by id](#cr_post)
* [Customized challenge record format](#cr_custom)
* [Posting a challenge response record (RR) to the blockchain](#rr_post)
* [Querying challenge response record](#rr_post)
* [Posting a signature record (SR) to the blockchain](#sr_post)
* [Querying signature records](#sr_post)
* [Revoking signature records](#sr_revoke)

## Posting and Querying Entity Identity Records <a name="eir_post"></a> ##
 
[Entity identity record](contracts/EntityIdentityRecord.sol) (EIR) contains all information that links an
entity to a certain identity and the corresponding public key. EIR is created during the key generation 
process and posted to the blockchain. EIR can be updated during the revocation process.

EIR can be registered by calling the [AuthCoin.registerEir](contracts/AuthCoin.sol#L54) function. It has the 
following input parameters:

| Name           | Type           | Description  |
|:-------------- | :--------------| :----------- |
| type           |bytes32         | Type of the EIR. Used to select EIR factory that will be used for EIR creation.|
| content        |bytes           | Content of the EIR. It may contain a public key or a X509 certificate|
| revoked        |bool            | Flag indicating whether EIR has been revoked |
| identifiers    |bytes32[]       | List of identifiers|
| hash           |bytes32         | SHA3 hash of the input data.|
| signature      |bytes           | Signature covering the input data|

The following _qtum-cli_ command can be used to register new EIR:

```
TODO
```

[AuthCoin.getEir](contracts/AuthCoin.sol#L207) function can be used to query EIR by the id.

```
TODO
```

## Revoking EIR <a name="eir_revoke"></a> ##

TODO

## Posting and Querying Challenge Record <a name="cr_post"></a> ##

Because Authcoin uses bidirectional validation and authentication process, both verifier and target create challenges 
for each other. The challenge record contract format and further information are stored in a 
[ChallengeRecord (CR)](contracts/ChallengeRecord.sol). 

CRs can be registered by calling the [AuthCoin.registerChallengeRecord](contracts/AuthCoin.sol#86) function and it has 
the following parameters:

| Name           | Type           | Description  |
|:-------------- | :--------------| :----------- |
| id             |int             | CR identifier |
| vae_id         |int             | Validation & authentication entry id. Identifier used to group together CRs, RRs and SRs|
| timestamp      |uint            | CR creation date|
| challengeType  |bytes32         | Type of the challenge|
| challenge      |bytes32         | Description of the challenge|
| verifierEir    |int             | Verifier EIR id|
| targetEir      |int             | Target EIR id|
| hash           |bytes32         | SHA3 hash of the input data|
| signature      |bytes           | Signature covering the input data|

The following _qtum-cli_ command can be used to register new challenge record:

```
TODO
```
## Posting a Challenge Response Record <a name="rr_post"></a> ##

A challenge response record (RR) is created as part of the validation and authentication process. The verifier and the 
target create responses to the corresponding challenge requests. A RR contains the response itself and related information. 

RR can be registered by calling the [AuthCoin.registerChallengeResponse](contracts/AuthCoin.sol#L142) function. It has the following 
input parameters:
 
| Name           | Type           | Description  |
|:-------------- | :--------------| :----------- |
| vaeId          |int             | Validation & authentication entry id.|
| challengeId    |int             | Challenge record id |
| timestamp      |uint            | RR creation date |
| response       |bytes32         | Response of the challenge |
| hash           |bytes32         | SHA3 hash of the input data|
| signature      |bytes           | Signature covering the input data|

```
TODO fix the table and add commands
```

# Development #

## Setup Development Environment ##

Truffle framework is used to write and test Solidity smart contracts. To set up the development environment we need 
to have _Node_ and _npm_ installed. After that we need to install the _TestRPC_ and _Truffle_:

```
npm install
```

## Directory Structure ##

The project directory has the following structure:

* **/contracts:** - Contains the Solidity source files for smart contracts. There is an important contract in here called Migrations.sol. Be sure **not to delete** this file!
* **/migrations:** - Truffle uses a migration system to handle smart contract deployments. A migration is an additional special smart contract that keeps track of changes.
* **/literature:** - Contains Authcoin related literature.
* **/test:** - Contains tests for smart contracts. All unit test should be written in Solidity.
* **truffle.js:** - Truffle's configuration file
* **ethpm.js:** -  Publishing and consuming Ethereum packages.

## Compile Smart Contracts ##

Execute `truffle compile` command

## Run Tests ##

```
npm run test
```

## Run Code Coverage ##

```
npm run coverage
```

## Run Linting ##

```
npm run lint
```
