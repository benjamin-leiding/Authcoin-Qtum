pragma solidity ^0.4.17;


/**
* @dev A challenge response record (RR) is created as part of the validation and authentication
* process. The verifier and the target create responses to the corresponding challenge requests.
* A RR contains the response itself and related information.
*/
contract ChallengeResponseRecord {

    bytes32 private vaeId;
    bytes32 private challengeRecordId;
    uint private blockNumber;
    bytes private response;
    bytes32 private hash;
    bytes private signature;

    address private owner;

    function ChallengeResponseRecord(
        bytes32 _vaeId,
        bytes32 _challengeRecordId,
        bytes _response,
        bytes32 _hash,
        bytes _signature,
        address _authCoinAddress
    ) {
        vaeId = _vaeId;
        challengeRecordId = _challengeRecordId;
        blockNumber = block.number;
        response = _response;
        owner = _authCoinAddress;
        hash = _hash;
        signature = _signature;
    }

    function getVaeId() public constant returns(bytes32) {
        return vaeId;
    }

    function getChallengeRecordId() public constant returns(bytes32) {
        return challengeRecordId;
    }

    function getBlockNumber() public constant returns(uint) {
        return blockNumber;
    }

    function getOwner() public constant returns(address) {
        return owner;
    }

}
