pragma solidity ^0.4.15;


import "./EntityIdentityRecord.sol";


// Contains all information about the validation & authentication (V&A) challenge record.
contract ChallengeRecord {

    // challenge request identifier
    int private id;

    // validation & authentication entry (VAE) id used to track the VAE throughout the hole V&A process.
    int private vaeId;

    // time of the block when the challenge request was added to the BC
    uint private timestamp;

    // type of the challenge.
    bytes32 private challengeType;

    // description of the challenge
    bytes32 private challenge;

    // verifier EIR
    EntityIdentityRecord private verifierEir;

    // target EIR
    EntityIdentityRecord private targetEir;

    bytes32 private hash;

    bytes private signature;

    address private owner;

    function ChallengeRecord(
        int _id,
        int _vaeId,
        uint _timestamp,
        bytes32 _type,
        bytes32 _challenge,
        EntityIdentityRecord _verifierEir,
        EntityIdentityRecord _targetEir,
        bytes32 _hash,
        bytes _signature,
        address _authCoinAddress) {
        id = _id;
        vaeId = _vaeId;
        timestamp = _timestamp;
        challengeType = _type;
        challenge = _challenge;
        verifierEir = _verifierEir;
        targetEir = _targetEir;
        hash = _hash;
        signature = _signature;
        owner = _authCoinAddress;
    }

    function getId() public returns(int) {
        return id;
    }

    function getVaeId() public returns (int) {
        return vaeId;
    }

    function getVerifier() public returns (EntityIdentityRecord) {
        return verifierEir;
    }

    function getTarget() public returns (EntityIdentityRecord) {
        return targetEir;
    }

}
