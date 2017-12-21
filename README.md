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
* [Querying CR by id](#vae_get)
* [Customized challenge record format](#cr_custom)
* [Posting a challenge response record (RR) to the blockchain](#rr_post)
* [Querying challenge response record](#vae_get)
* [Posting a signature record (SR) to the blockchain](#sr_post)
* [Querying signature records](#vae_get)
* [Revoking signature records](#sr_revoke)

## Posting and Querying Entity Identity Records <a name="eir_post"></a> ##
 
[Entity identity record](contracts/EntityIdentityRecord.sol) (EIR) contains all information that links an
entity to a certain identity and the corresponding public key. EIR is created during the key generation 
process and posted to the blockchain. EIR can be updated during the revocation process.

EIR can be registered by calling the [AuthCoin.registerEir](contracts/AuthCoin.sol#L56) function. It has the
following input parameters:

| Name           | Type           | Description  |
|:-------------- | :--------------| :----------- |
| content        |bytes           | Content of the EIR. It may contain a public key or a X509 certificate|
| contentType    |bytes32         | Type of the EIR. Used to select EIR factory that will be used for EIR creation.|
| identifiers    |bytes32[]       | List of identifiers|
| hash           |bytes32         | SHA3 hash of the input data.|
| signature      |bytes           | Signature covering the input data|

The following _qtum-cli_ command can be used to register new EIR:

```
qtum-cli sendtocontract <authcoin_conract_address> <encoded_function_call>
```

The following _ethabi_ command can be used to generate encoded function call

```
ethabi encode function <authcoin_contract_abi> registerEir -p <content> <contentType> <identifiers> <hash> <signarure>
```

[AuthCoin.getEir](contracts/AuthCoin.sol#L254) function can be used to query EIR by the id.

The following _qtum-cli_ command can be used to query EIR:

```
qtum-cli callcontract <authcoin_conract_address> <encoded_function_call>
```

The following _ethabi_ command can be used to generate encoded function call

```
ethabi encode function <authcoin_contract_abi> getEir -p <eirId> <revokingSignature>
```

## Revoking EIR <a name="eir_revoke"></a> ##

EIRs can be revoked by calling the [AuthCoin.revokeEir](contracts/AuthCoin.sol#L96) function and it has following parameters:

| Name              | Type           | Description  |
|:----------------- | :--------------| :----------- |
| eirId             |bytes32         | EIR identifier (SHA3 hash of EIR content) |
| revokingSignature |bytes           | Signature covering SHA3 hash of EIR data |

The following _qtum-cli_ command can be used to revoke EIR:

```
qtum-cli sendtocontract <authcoin_conract_address> <encoded_function_call>
```

The following _ethabi_ command can be used to generate encoded function call

```
ethabi encode function <authcoin_contract_abi> revokeEir -p <eirId> <revokingSignature>
```

## Posting Challenge Record <a name="cr_post"></a> ##

Because Authcoin uses bidirectional validation and authentication process, both verifier and target create challenges 
for each other. The challenge record is stored as a struct in
[ValidationAuthenticationEntry (VAE)](contracts/ValidationAuthenticationEntry.sol#L18).

CRs can be registered by calling the [AuthCoin.registerChallengeRecord](contracts/AuthCoin.sol#105) function and it has
the following parameters:

| Name           | Type           | Description  |
|:-------------- | :--------------| :----------- |
| id             |bytes32         | CR identifier |
| vaeId          |bytes32         | Validation & authentication entry id. Identifier used to group together CRs, RRs and SRs|
| challengeType  |bytes32         | Type of the challenge|
| challenge      |bytes           | Description of the challenge|
| verifierEir    |bytes32         | Verifier EIR id|
| targetEir      |bytes32         | Target EIR id|
| hash           |bytes32         | SHA3 hash of the input data|
| signature      |bytes           | Signature covering the input data|

The following _qtum-cli_ command can be used to register new challenge record:

```
qtum-cli sendtocontract <authcoin_conract_address> <encoded_function_call>
```

The following _ethabi_ command can be used to generate encoded function call

```
ethabi encode function <authcoin_contract_abi> registerChallengeRecord -p <id> <vaeId> <challengeType> <challenge> <verifierEir> <targetEir> <hash> <signature>
```


## Posting Challenge Response Record <a name="rr_post"></a> ##

A challenge response record (RR) is created as part of the validation and authentication process. The verifier and the 
target create responses to the corresponding challenge requests. A RR contains the response itself and related information. 
The challenge response record is stored as a struct in [ValidationAuthenticationEntry (VAE)](contracts/ValidationAuthenticationEntry.sol#L30).

RR can be registered by calling the [AuthCoin.registerChallengeResponse](contracts/AuthCoin.sol#L166) function. It has the following
input parameters:

| Name           | Type           | Description  |
|:-------------- | :--------------| :----------- |
| vaeId          |bytes32         | Validation & authentication entry id.|
| challengeId    |bytes32         | Challenge record id |
| response       |bytes           | Response of the challenge |
| hash           |bytes32         | SHA3 hash of the input data|
| signature      |bytes           | Signature covering the input data|


The following _qtum-cli_ command can be used to register new challenge response record:

```
qtum-cli sendtocontract <authcoin_conract_address> <encoded_function_call>
```

The following _ethabi_ command can be used to generate encoded function call

```
ethabi encode function <authcoin_contract_abi> registerChallengeResponse -p <vaeId> <challengeId> <response> <hash> <signature>
```


## Posting Challenge Signature Record <a name="sr_post"></a> ##

A challenge signature record (SR) is created as part of the validation and authentication process. The verifier and the
target create signatures to the corresponding challenge response requests. A SR contains the signature itself and related information.
The challenge response record is stored as a struct in [ValidationAuthenticationEntry (VAE)](contracts/ValidationAuthenticationEntry.sol#L40).

SR can be registered by calling the [AuthCoin.registerChallengeSignature](contracts/AuthCoin.sol#L192) function. It has the following
input parameters:

| Name            | Type           | Description  |
|:--------------  | :--------------| :----------- |
| vaeId           |bytes32         | Validation & authentication entry id.|
| challengeId     |bytes32         | Challenge record id |
| expirationBlock |uint            | Block number when the signature expires |
| successful      |bool            | True if corresponding chalenge response is considered valid|
| hash            |bytes32         | SHA3 hash of the input data|
| signature       |bytes           | Signature covering the input data|

The following _qtum-cli_ command can be used to register new challenge signature record:

```
qtum-cli sendtocontract <authcoin_conract_address> <encoded_function_call>
```

The following _ethabi_ command can be used to generate encoded function call

```
ethabi encode function <authcoin_contract_abi> registerChallengeSignature -p <vaeId> <challengeId> <expirationBlock> <successful> <hash> <signature>
```

## Querying Validation Authentication Entry and CR, RR, SR records <a name="vae_get"></a> ##

Because Authcoin uses bidirectional validation and authentication process, both verifier and target create challenges, challenge responses and challenge signatures
for each other. All this information is stored in contract validation authentication entry (VAE)
[ValidationAuthenticationEntry (VAE)](contracts/ValidationAuthenticationEntry.sol)

VAE contract address can be queried by calling the [AuthCoin.getVae](contracts/AuthCoin.sol#L261) function. It has the following
input parameters:

| Name            | Type           | Description  |
|:--------------  | :--------------| :----------- |
| vaeId           |bytes32         | Validation & authentication entry id.|

The following _qtum-cli_ command can be used to register new challenge signature record:

```
qtum-cli callcontract <authcoin_conract_address> <encoded_function_call>
```

The following _ethabi_ command can be used to generate encoded function call

```
ethabi encode function <authcoin_contract_abi> getVae -p <vaeId>
```

CRs can be queried by calling the [ValidationAuthenticationEntry.getChallenge](contracts/ValidationAuthenticationEntry.sol#239) function and it has
the following parameters:

| Name           | Type           | Description  |
|:-------------- | :--------------| :----------- |
| challengeId    |bytes32         | CR identifier |


The following _qtum-cli_ command can be used to register new challenge record:

```
qtum-cli callcontract <vae_conract_address> <encoded_function_call>
```

The following _ethabi_ command can be used to generate encoded function call

```
ethabi encode function <authcoin_contract_abi> getChallenge -p <challengeId>
```

RRs can be queried by calling the [ValidationAuthenticationEntry.getChallengeResponse](contracts/ValidationAuthenticationEntry.sol#261) function and it has
the following parameters:

| Name           | Type           | Description  |
|:-------------- | :--------------| :----------- |
| challengeId    |bytes32         | CR identifier |

The following _qtum-cli_ command can be used to register new challenge record:

```
qtum-cli callcontract <vae_conract_address> <encoded_function_call>
```

The following _ethabi_ command can be used to generate encoded function call

```
ethabi encode function <authcoin_contract_abi> getChallengeResponse -p <challengeId>
```


SRs can be queried by calling the [ValidationAuthenticationEntry.getChallengeSignature](contracts/ValidationAuthenticationEntry.sol#273) function and it has
the following parameters:

| Name           | Type           | Description  |
|:-------------- | :--------------| :----------- |
| challengeId    |bytes32         | CR identifier |


The following _qtum-cli_ command can be used to register new challenge record:

```
qtum-cli callcontract <vae_conract_address> <encoded_function_call>
```

The following _ethabi_ command can be used to generate encoded function call

```
ethabi encode function <authcoin_contract_abi> getChallengeSignature -p <challengeId>
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

## Application Binary Interface ##

The ABI, Application Binary Interface, is basically how you call functions in a contract and get data back.

```
An ABI determines such details as how functions are called and in which binary format information should be passed from one program component to the next...
```

An Ethereum smart contract is bytecode, EVM, on the Ethereum blockchain. Among the EVM, there could be several functions in a contract. An ABI is necessary so that you can specify which function in the contract to invoke, as well as get a guarantee that the function will return data in the format you are expecting.

**ethabi** library encodes function calls and decodes their output. For more information visit the project page at https://github.com/paritytech/ethabi

## Using Smart Contracts with Qtum ##

The smart contract interface in Qtum still requires some technical knowledge. The GUI is not completed yet, so all smart contract interation must happen either using qtum-cli at the command line, or in the debug window of qtum-qt.

For more information how to call contracts on Qtum visit https://github.com/qtumproject/qtum/blob/master/doc/sparknet-guide.md
