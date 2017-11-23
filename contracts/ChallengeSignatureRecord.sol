pragma solidity ^0.4.17;


/**
* @dev Contains all information regarding a V&A signature
*/
contract ChallengeSignatureRecord {

    bytes32 private vaeId;

    bytes32 private challengeRecordId;

    uint private blockNumber;

    uint private expirationBlock;

    bool private revoked;

    bool private successful;

    bytes32[] private hash;

    bytes private signature;

    address private creator;

    function ChallengeSignatureRecord(
        bytes32 _vaeId,
        bytes32 _challengeRecordId,
        uint _expirationBlock,
        bool _successful,
        bytes32[] _hash,
        bytes _signature,
        address _authCoinAddress) {
        vaeId = _vaeId;
        challengeRecordId = _challengeRecordId;
        blockNumber = block.number;
        expirationBlock = _expirationBlock;
        revoked = false;
        successful = _successful;
        hash = _hash;
        signature = _signature;
        creator = _authCoinAddress;
    }

    function getVaeId() public view returns (bytes32) {
        return vaeId;
    }

    function getChallengeRecordId() public view returns (bytes32) {
        return challengeRecordId;
    }

    function getBlockNumber() public view returns (uint) {
        return blockNumber;
    }

    function getExpirationBlock() public view returns (uint) {
        return expirationBlock;
    }

    function isSuccessful() public view returns (bool) {
        return successful;
    }

    // TODO getHash()
    // TODO getSignature

    function getCreator() public view returns (address) {
        return creator;
    }


}
