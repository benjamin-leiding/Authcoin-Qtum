pragma solidity ^0.4.17;


import "./EntityIdentityRecord.sol";


// Contains all information about the validation & authentication (V&A) challenge record.
contract ChallengeRecord {

    // challenge request identifier
    bytes32 private id;

    // validation & authentication entry (VAE) id used to track the VAE throughout the hole V&A process.
    bytes32 private vaeId;

    // number of the block when the challenge request was added to the BC
    uint private timestamp;

    // type of the challenge.
    bytes32 private challengeType;

    // description of the challenge
    bytes private challenge;

    // verifier EIR
    EntityIdentityRecord private verifierEir;

    // target EIR
    EntityIdentityRecord private targetEir;

    bytes32 private hash;

    bytes private signature;

    address private owner;

    function ChallengeRecord(
        bytes32 _id,
        bytes32 _vaeId,
        bytes32 _type,
        bytes _challenge,
        EntityIdentityRecord _verifierEir,
        EntityIdentityRecord _targetEir,
        bytes32 _hash,
        bytes _signature,
        address _authCoinAddress) {
        id = _id;
        vaeId = _vaeId;
        timestamp = block.number;
        challengeType = _type;
        challenge = _challenge;
        verifierEir = _verifierEir;
        targetEir = _targetEir;
        hash = _hash;
        signature = _signature;
        owner = _authCoinAddress;
    }

    function getId() public view returns(bytes32) {
        return id;
    }

    function getVaeId() public view returns (bytes32) {
        return vaeId;
    }

    function getVerifier() public view returns (EntityIdentityRecord) {
        return verifierEir;
    }

    function getTarget() public view returns (EntityIdentityRecord) {
        return targetEir;
    }

}
