pragma solidity ^0.4.17;


import "./Identifiable.sol";


/**
* @dev A challenge response record (RR) is created as part of the validation and authentication
* process. The verifier and the target create responses to the corresponding challenge requests.
* A RR contains the response itself and related information.
*/
contract ChallengeResponseRecord is Identifiable {

    bytes32 private vaeId;

    bytes32 private challengeRecordId;

    uint private blockNumber;

    bytes private response;

    bytes32 private hash;

    bytes private signature;

    function ChallengeResponseRecord(
        bytes32 _vaeId,
        bytes32 _challengeRecordId,
        bytes _response,
        bytes32 _hash,
        bytes _signature,
        address _owner) {
        vaeId = _vaeId;
        challengeRecordId = _challengeRecordId;
        blockNumber = block.number;
        response = _response;
        hash = _hash;
        signature = _signature;
        owner = _owner;
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

    function getHash() public view returns (bytes32) {
        return hash;
    }

    function getSignature() public view returns (bytes) {
        return signature;
    }

}
