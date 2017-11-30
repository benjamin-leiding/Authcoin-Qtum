pragma solidity ^0.4.17;


import "./EntityIdentityRecord.sol";
import "./Identifiable.sol";


/**
* @dev Contains all information about the validation & authentication (V&A) challenge record.
*/
contract ChallengeRecord is Identifiable {

    // challenge request identifier
    bytes32 private id;

    // validation & authentication entry (VAE) id used to track the VAE throughout the hole V&A process.
    bytes32 private vaeId;

    // number of the block when the challenge request was added to the BC
    uint private blockNumber;

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

    function ChallengeRecord(
        bytes32 _id,
        bytes32 _vaeId,
        bytes32 _type,
        bytes _challenge,
        EntityIdentityRecord _verifierEir,
        EntityIdentityRecord _targetEir,
        bytes32 _hash,
        bytes _signature,
        address _owner) {
        id = _id;
        vaeId = _vaeId;
        blockNumber = block.number;
        challengeType = _type;
        challenge = _challenge;
        verifierEir = _verifierEir;
        targetEir = _targetEir;
        hash = _hash;
        signature = _signature;
        owner = _owner;
    }

    function getId() public view returns(bytes32) {
        return id;
    }

    function getVaeId() public view returns (bytes32) {
        return vaeId;
    }

    function getBlockNumber() public view returns (uint) {
        return blockNumber;
    }

    function getVerifier() public view returns (EntityIdentityRecord) {
        return verifierEir;
    }

    function getTarget() public view returns (EntityIdentityRecord) {
        return targetEir;
    }

    function getChallengeType() public view returns (bytes32) {
        return challengeType;
    }

    function getHash() public view returns (bytes32) {
        return hash;
    }

    function getSignature() public view returns (bytes) {
        return signature;
    }

}
