pragma solidity ^0.4.15;


// Contains information about the challenge response.
contract ChallengeResponseRecord {

    int private vaeId;
    int private challengeRecordId;
    uint private timestamp;
    bytes32 private response;
    bytes32 private hash;
    bytes private signature;

    address private owner;

    function ChallengeResponseRecord(
        int _vaeId,
        int _challengeRecordId,
        uint _timestamp,
        bytes32 _response,
        bytes32 _hash,
        bytes _signature,
        address _authCoinAddress
    ) {
        vaeId = _vaeId;
        challengeRecordId = _challengeRecordId;
        timestamp = _timestamp;
        response = _response;
        owner = _authCoinAddress;
        hash = _hash;
        signature = _signature;
    }

    function getVaeId() public constant returns(int) {
        return vaeId;
    }

    function getChallengeRecordId() public constant returns(int) {
        return challengeRecordId;
    }

    function getTimestamp() public constant returns(uint) {
        return timestamp;
    }

    function getOwner() public constant returns(address) {
        return owner;
    }

}
