pragma solidity ^0.4.17;


import "./ChallengeRecord.sol";
import "./ChallengeResponseRecord.sol";
import "./EntityIdentityRecord.sol";


/*
* @dev Tracks and stores the information produced by the validation & authentication process. During the V&A process,
*      the verifier and target:
*            1. exchange challenges (CR - ChallengeRecord) with each other and
*            2. create the corresponding responses (RR - ResponseRecord) and
*            3. both entities evaluate the received responses and create corresponding signatures (SR - SignatureRecord)
*               depending on whether they are satisfied with the received response or not.
*/
contract ValidationAuthenticationEntry {

    // Identifier used to track the VAE throughout the hole V&A process.
    bytes32 private vaeId;

    // Block number when the VAE was created and the first CR was attached to the VAE by verifier. If 'target'
    // does not create a corresponding challenge for the verifier within 24h, we assume the V&A procedure to
    // be failed.
    uint private blockNumber;

    // cr_id = >CR
    mapping(bytes32 => ChallengeRecord) private challenges;
    // cr_id array
    bytes32[] private challengeIdArray;

    // cr_id => ChallengeResponseRecord
    mapping(int => ChallengeResponseRecord) private responses;

    // cr_id array
    bytes32[] private responseIdArray;

    // Challenge record submitted by verifier
    ChallengeRecord private verifierChallenge; // TODO remove

    // Challenge record submitted by target
    ChallengeRecord private targetChallenge; // TODO remove

    // Verifier's response to Target's challenge
    ChallengeResponseRecord private verifierResponse; // TODO remove

    // Target's response to Verifier's challenge
    ChallengeResponseRecord private targetResponse; // TODO remove



    address private creator; // TODO rename

    // ChallengeSignatureRecord private verifierSignatureRecord;
    // ChallengeSignatureRecord private targetSignatureRecord;

    // Constructor to create a new V&A entry.
    function ValidationAuthenticationEntry(
        bytes32 _vaeId,
        address _authCoinAddress) {
        vaeId = _vaeId;
        blockNumber = block.number;
        creator = _authCoinAddress;
    }

    function getVaeId() public view returns(bytes32) {
        return vaeId;
    }

    function getBlockNumber() public view returns(uint) {
        return blockNumber;
    }

    function getCreator() public view returns(address) {
        return creator;
    }

    function addChallengeRecord(ChallengeRecord _cr) onlyCreator public returns (bool) {
        // _cr isn't zero address
        require(address(_cr) != address(0));
        require(_cr.getVaeId() == vaeId); //test ok
        // 0 or 1 challenges
        require(challengeIdArray.length < 2); // test ok
        bytes32 crId = _cr.getId();
        if(challengeIdArray.length == 1) {
            require(challenges[crId] == address(0)); // test ok
            ChallengeRecord previous = challenges[challengeIdArray[0]];
            require(previous.getVerifier() == _cr.getTarget()); // test ok
            require(_cr.getVerifier() == previous.getTarget()); // test ok
        }

        challenges[crId] = _cr;
        challengeIdArray.push(crId);
        return true;
    }

    function addChallengeResponseRecord(ChallengeResponseRecord _rr) onlyCreator public returns (bool) {
        require(challengeIdArray.length == 2);
        require(responseIdArray.length < 2);
        require(address(_rr) != address(0));
        require(_rr.getVaeId() == vaeId);
        // challenge exists
        require(address(challenges[_rr.getChallengeRecordId()]) != address(0));
        // challenge response doesn't exist
        require(address(responses[_rr.getChallengeRecordId()]) == address(0));

        // TODO rr is signed by correct EIR

        responses[_rr.getChallengeRecordId()] = _rr;
        responseIdArray.push(_rr.getId());
        return true;
    }

    function getChallengesCount() public view returns(uint) {
        return challengeIdArray.length;
    }

    function getVerifierChallengeRecord() public view returns (ChallengeRecord) {
        return verifierChallenge;
    }

    function getTargetChallengeRecord() public view returns (ChallengeRecord) {
        return targetChallenge;
    }

    // Returns the challenge record.
    // 0 = verifier
    // 1 = target
    function getChallengeRecord(int _type) private view returns (ChallengeRecord) {
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
    function getStatus() public view returns (uint) {
        if (targetChallenge == address(0) || verifierChallenge == address(0)) {
            return 0;
        }
        if (verifierResponse == address(0) || targetResponse == address(0)) {
            return 1;
        }
        /*
        if (verifierSignatureRecord == address(0) || targetSignatureRecord == address(0)) {
            return 2;
        }
    */
        return 3;
    }

    modifier onlyCreator() {
        //TODO should only be called by authCoin contract
        //require(msg.sender == creator);
        _;
    }

}
