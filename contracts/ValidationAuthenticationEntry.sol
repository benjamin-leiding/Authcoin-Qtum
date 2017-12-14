pragma solidity ^0.4.17;


import "./Identifiable.sol";
import "./EntityIdentityRecord.sol";


/*
* @dev Tracks and stores the information produced by single validation & authentication process. During the V&A process,
* the verifier and target:
*   1. exchange challenges (CR - ChallengeRecord) with each other and
*   2. create the corresponding responses (RR - ResponseRecord) and
*   3. both entities evaluate the received responses and create corresponding signatures (SR - SignatureRecord)
*      depending on whether they are satisfied with the received response or not.
*/
contract ValidationAuthenticationEntry is Identifiable {

    struct ChallengeRecord {
        bytes32 id;
        uint blockNumber;
        bytes32 challengeType;
        bytes challenge;
        address verifierEir;
        address targetEir;
        bytes32 hash;
        bytes signature;
        address creator;
    }

    struct ChallengeResponseRecord {
        bytes32 vaeId;
        bytes32 challengeRecordId;
        uint blockNumber;
        bytes response;
        bytes32 hash;
        bytes signature;
        address creator;
    }

    struct ChallengeSignatureRecord {
        bytes32 vaeId;
        bytes32 challengeRecordId;
        uint blockNumber;
        uint expirationBlock;
        bool revoked;
        bool successful;
        bytes32 hash;
        bytes signature;
        address creator;
    }

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

    event LogNewChallengeRecord(ChallengeRecord cr, bytes32 challengeType, bytes32 id, bytes32 vaeId);

    event LogNewChallengeResponseRecord(ChallengeResponseRecord responseAddress, bytes32 challengeId);

    event LogNewChallengeSignatureRecord(ChallengeSignatureRecord sr, bytes32 challengeId, bytes32 vaeId);

    // Constructor to create a new V&A entry.
    function ValidationAuthenticationEntry(
        bytes32 _vaeId,
        address _owner) {
        vaeId = _vaeId;
        blockNumber = block.number;
        owner = _owner;
    }

    function getVaeId() public view returns(bytes32) {
        return vaeId;
    }

    function getBlockNumber() public view returns(uint) {
        return blockNumber;
    }

    function addChallengeRecord(
        bytes32 _crId,
        bytes32 _vaeId,
        bytes32 _challengeType,
        bytes _challenge,
        address _verifierEir,
        address _targetEir,
        bytes32 _hash,
        bytes _signature,
        address _creator
    ) onlyCreator public returns (bool) {
        require(vaeId == _vaeId);
        // 0 or 1 challenges
        require(challengeIdArray.length < 2); // test ok

        ChallengeRecord memory cr = ChallengeRecord(
            _crId,
            block.number,
            _challengeType,
            _challenge,
            _verifierEir,
            _targetEir,
            _hash,
            _signature,
            _creator
        );
        // TODO CR is signed by correct EIR

        if (challengeIdArray.length == 1) {
            require(challenges[_crId].creator == address(0)); // test ok
            ChallengeRecord previous = challenges[challengeIdArray[0]];
            require(previous.verifierEir == _targetEir); // test ok
            require(_verifierEir == previous.targetEir); // test ok
        }

        challenges[_crId] = cr;
        challengeIdArray.push(_crId);
        LogNewChallengeRecord(
             cr,
             _challengeType,
             _crId,
             _vaeId
         );
        return true;
    }

    function addChallengeResponseRecord(
        bytes32 _vaeId,
        bytes32 _challengeRecordId,
        bytes _response,
        bytes32 _hash,
        bytes _signature,
        address _creator
    ) onlyCreator public returns (bool) {
        require(challengeIdArray.length == 2);
        require(responseIdArray.length < 2);

        require(vaeId == _vaeId);
        // challenge exists
        require(challenges[_challengeRecordId].creator != address(0));
        // challenge response doesn't exist
        require(responses[_challengeRecordId].creator == address(0));

        // ensure CRR hash is correct
        require(keccak256(_vaeId, _challengeRecordId, _response) == _hash);

        // ensure CRR signature is correct
        ChallengeRecord cr = challenges[_challengeRecordId];
        require(EntityIdentityRecord(cr.targetEir).verifySignature(BytesUtils.bytes32ToString(_hash), _signature));

        ChallengeResponseRecord memory rr = ChallengeResponseRecord(
            _vaeId,
            _challengeRecordId,
            block.number,
            _response,
            _hash,
            _signature,
            _creator
        );

        responses[_challengeRecordId] = rr;
        responseIdArray.push(_challengeRecordId);

        LogNewChallengeResponseRecord(rr, _challengeRecordId);
        return true;
    }

    function addChallengeSignatureRecord(
        bytes32 _vaeId,
        bytes32 _challengeRecordId,
        uint _expirationBlock,
        bool _successful,
        bytes32 _hash,
        bytes _signature,
        address _creator
    ) onlyCreator public returns (bool) {
        require(challengeIdArray.length == 2); // ok
        require(responseIdArray.length == 2); // ok
        require(signatureIdArray.length < 2);

        // challenge exists
        ChallengeRecord cr = challenges[_challengeRecordId];
        require(cr.creator != address(0));
        // challenge response exist
        require(responses[_challengeRecordId].creator != address(0));
        // challenge response doesn't exist
        require(signatures[_challengeRecordId].creator == address(0));
        // ensure SR hash is correct
        require(keccak256(_vaeId, _challengeRecordId, _expirationBlock, _successful) == _hash);
        // ensure SR signature is correct

        require(EntityIdentityRecord(cr.verifierEir).verifySignature(BytesUtils.bytes32ToString(_hash), _signature));

        ChallengeSignatureRecord memory sr = ChallengeSignatureRecord(
            _vaeId,
            _challengeRecordId,
            block.number,
            _expirationBlock,
            false,
            _successful,
            _hash,
            _signature,
            _creator
        );

        signatures[_challengeRecordId] = sr;
        signatureIdArray.push(_challengeRecordId);
        LogNewChallengeSignatureRecord(sr, _challengeRecordId, _vaeId);
        return true;
    }

    function getChallengeCount() public view returns(uint) {
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
            if (EntityIdentityRecord(cr.verifierEir).getId() == eirId || EntityIdentityRecord(cr.targetEir).getId() == eirId) {
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

    function getChallengeRecordData(bytes32 challengeId) public view returns(
        bytes32,
        uint,
        bytes32,
        bytes,
        address,
        address,
        bytes32,
        bytes) {
        ChallengeRecord storage cr = challenges[challengeId];
        var length = cr.challenge.length;
        bytes memory challenge = copyArray(cr.challenge);
        bytes memory signature = copyArray(cr.signature);
        return (
        cr.id,
        cr.blockNumber,
        cr.challengeType,
        challenge,
        cr.verifierEir,
        cr.targetEir,
        cr.hash,
        signature);
    }

    function copyArray(bytes a) private view returns(bytes) {
        bytes memory second = new bytes(a.length);

        for (uint i = 0; i < a.length; i++) {
            second[i] = a[i];
        }
        return second;
    }

}
