pragma solidity ^0.4.15;


import "./ChallengeRecord.sol";
import "./ChallengeResponseRecord.sol";
import "./EntityIdentityRecord.sol";


// Used to track and store the information produced by the validation & authentication process. During the V&A process,
// the verifier and target
//
//     1. exchange challenges (CR - ChallengeRecord) with each other and
//     2. create the corresponding responses (RR - ResponseRecord) and
//     3. both entities evaluate the received responses and create corresponding signatures (SR - SignatureRecord)
//        depending on whether they are satisfied with the received response or not.
//
// TODO describe the situations when V&A fails (including timeouts).
contract ValidationAuthenticationEntry {

    // Identifier used to track the VAE throughout the hole V&A process.
    int private vaeId;

    // Block time when the VAE was created and the first CR was attached to the VAE by verifier. If 'target'
    // does not create a corresponding challenge for the verifier within 24h, we assume the V&A procedure to
    // be failed.
    uint private createdAt;

    // Verifier's entity identity record
    EntityIdentityRecord private verifier;

    // Target's entity identity record
    EntityIdentityRecord private target;

    // Challenge record submitted by verifier
    ChallengeRecord private verifierChallenge;

    // Challenge record submitted by target
    ChallengeRecord private targetChallenge;

    // Verifier's response to Target's challenge
    ChallengeResponseRecord private verifierResponse;

    // Target's response to Verifier's challenge
    ChallengeResponseRecord private targetResponse;

    address private owner;

    // ChallengeSignatureRecord private verifierSignatureRecord;
    // ChallengeSignatureRecord private targetSignatureRecord;

    // Constructor to create a new V&A entry.
    function ValidationAuthenticationEntry(int _vaeId, EntityIdentityRecord _verifier, EntityIdentityRecord _target, address _authCoinAddress) {
        require(address(_verifier) != address(0));
        require(address(_target) != address(0));
        require(_authCoinAddress != address(0));
        require(address(_target) != address(_verifier));

        vaeId = _vaeId;
        verifier = _verifier;
        target = _target;
        createdAt = block.timestamp;
        owner = _authCoinAddress;
    }

    function getVaeId() public returns(int) {
        return vaeId;
    }

    function getTimestamp() public returns(uint) {
        return createdAt;
    }

    function getVerifier() public returns(address) {
        return address(verifier);
    }

    function getTarget() public returns(address) {
        return address(target);
    }

    function getOwner() public returns(address) {
        return owner;
    }

    function setChallenge(ChallengeRecord _cr, int8 _challengeType) onlyOwner public returns (bool) {
        require(address(_cr) != address(0));
        require(_cr.getVaeId() == vaeId);
        // CR can not be added multiple times
        //require(address(getChallengeRecord(_challengeType)) == address(0));
        // TODO is challenge record signed by 'verifier' or 'target'

        if (_challengeType == 0) {
            require(_cr.getVerifier() == verifier);
            require(_cr.getTarget() == target);
            verifierChallenge = _cr;
        } else {
            require(_cr.getTarget() == verifier);
            require(_cr.getVerifier() == target);
            targetChallenge = _cr;
        }
        return true;
    }

    // Returns the challenge record.
    // 0 = verifier
    // 1 = target
    function getChallengeRecord(int _type) private returns (ChallengeRecord) {
        if (_type == 0) {
            return verifierChallenge;
        }
        return targetChallenge;
    }

    // Returns the status of the current V&A process. Returns one of the following values:
    //    0 - waiting_challenge_record
    //    1 - waiting_challenge_response_record(s)
    //    2 - waiting_challenge_signature_record(s)
    //    3 - failed
    //    4 - revoked
    //    5 - successful
    function getStatus() public returns (uint) {
        if (targetChallenge == address(0) || verifierChallenge == address(0)) {
            return 0;
        }
        if (verifierResponse == address(0) || targetResponse == address(0)) {
            return 1;
        }
        //if (verifierSignatureRecord == address(0) || targetSignatureRecord == address(0)) {
        //    return 2;
        //}

        return 3;
    }

    modifier onlyOwner() {
        //TODO should only be called by authCoin contract
        //require(msg.sender == owner);
        _;
    }

}
