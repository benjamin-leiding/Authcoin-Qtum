pragma solidity ^0.4.17;


import "./ChallengeRecord.sol";
import "./ChallengeResponseRecord.sol";
import "./ChallengeSignatureRecord.sol";
import "./EntityIdentityRecord.sol";


/*
* @dev Tracks and stores the information produced by single validation & authentication process. During the V&A process,
* the verifier and target:
*   1. exchange challenges (CR - ChallengeRecord) with each other and
*   2. create the corresponding responses (RR - ResponseRecord) and
*   3. both entities evaluate the received responses and create corresponding signatures (SR - SignatureRecord)
*      depending on whether they are satisfied with the received response or not.
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
    mapping(bytes32 => ChallengeResponseRecord) private responses;

    // cr_id array
    bytes32[] private responseIdArray;

    // cr_id => ChallengeSignatureRecord
    mapping(bytes32 => ChallengeSignatureRecord) private signatures;

    // cr_id array
    bytes32[] private signatureIdArray;

    address private creator;

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

        // TODO CR is signed by correct EIR

        if (challengeIdArray.length == 1) {
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
        responseIdArray.push(_rr.getChallengeRecordId());
        return true;
    }

    function addChallengeSignatureRecord(ChallengeSignatureRecord _sr) onlyCreator public returns (bool) {
        require(address(_sr) != address(0));
        require(challengeIdArray.length == 2); // ok
        require(responseIdArray.length == 2); // ok
        require(signatureIdArray.length < 2);

        // challenge exists
        require(address(challenges[_sr.getChallengeRecordId()]) != address(0));
        // challenge response exist
        require(address(responses[_sr.getChallengeRecordId()]) != address(0));
        // challenge response doesn't exist
        require(address(signatures[_sr.getChallengeRecordId()]) == address(0));

        // TODO sr is signed by correct EIR

        signatures[_sr.getChallengeRecordId()] = _sr;
        signatureIdArray.push(_sr.getChallengeRecordId());
        return true;
    }

    // TODO rename to getChallengeCount
    function getChallengesCount() public view returns(uint) {
        return challengeIdArray.length;
    }

    function getChallengeIds() public view returns(bytes32[]) {
        return challengeIdArray;
    }

    function getChallenge(bytes32 challengeId) public view returns(ChallengeRecord) {
        return challenges[challengeId];
    }

    function isParticipant(bytes32 eirId) public view returns(bool) {
        for (uint i = 0; i < challengeIdArray.length; i++) {
            ChallengeRecord cr = challenges[challengeIdArray[i]];
            if (cr.getVerifier().getId() == eirId || cr.getTarget().getId() == eirId) {
                return true;
            }
        }
        return false;
    }

    function getChallengeResponseCount() public view returns(uint) {
        return responseIdArray.length;
    }

    function getChallengeResponseIds() public view returns(bytes32[]) {
        return responseIdArray;
    }

    function getChallengeResponse(bytes32 challengeId) public view returns(ChallengeResponseRecord) {
        return responses[challengeId];
    }

    function getChallengeSignatureCount() public view returns(uint) {
        return signatureIdArray.length;
    }

    function getChallengeSignatureIds() public view returns(bytes32[]) {
        return signatureIdArray;
    }

    function getChallengeSignature(bytes32 challengeId) public view returns(ChallengeSignatureRecord) {
        return signatures[challengeId];
    }

    modifier onlyCreator() {
        //TODO should only be called by authCoin contract
        //require(msg.sender == creator);
        _;
    }

}
