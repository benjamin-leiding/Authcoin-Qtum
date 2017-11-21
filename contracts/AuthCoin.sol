pragma solidity ^0.4.17;


import "zeppelin/ownership/Ownable.sol";
import "./EntityIdentityRecord.sol";
import "./ChallengeRecord.sol";
import "./ChallengeResponseRecord.sol";
import "./ValidationAuthenticationEntry.sol";
import "./signatures/SignatureVerifier.sol";


// Main entry point for Authcoin protocol.
contract AuthCoin is Ownable {

    // stores EIR values (eir_id => EntityIdentityRecord)
    mapping (bytes32 => EntityIdentityRecord) private eirIdToEir;

    // stores the id's of Entity Identity Records
    bytes32[] private eirIdList;

    // stores the values of ValidationAuthenticationEntry (vae_id => ValidationAuthenticationEntry)
    mapping (bytes32 => ValidationAuthenticationEntry) private vaeIdToVae;

    // stores the id's of ValidationAuthenticationEntry
    bytes32[] private vaeIdList;

    // stores known signature verifier contracts (eir type =>  SignatureVerifier)
    mapping (bytes32 => SignatureVerifier) private signatureVerifiers;

    event LogNewEir(bytes32 id, EntityIdentityRecord eir, bytes32 contentType);

    event LogRevokedEir(bytes32 id);

    event LogNewChallengeRecord(ChallengeRecord cr, bytes32 challengeType, bytes32 id, bytes32 vaeId);

    event LogNewChallengeResponseRecord(ChallengeResponseRecord rr, int id, int vaeId, int crId);

    event LogNewVae(address vaeAddress, bytes32 id);

    event LogNewSignatureVerifier(SignatureVerifier a, bytes32 eirType);

    function AuthCoin() {
        //TODO default verifier
    }

    // Registers a new EIR
    function registerEir(
        bytes _content,
        bytes32 _contentType,
        bytes32[] _identifiers, // e-mail address, username, age, etc
        bytes32 _hash,
        bytes _signature) public returns (bool) {

        // ensure content type exists
        require(signatureVerifiers[_contentType] != address(0));

        // ensure EIR hash is correct
        // TODO implement

        // ensure signature is correct
        // TODO implement

        // calculate id and ensure it doesn't exist
        var id = keccak256(_content);
        require(eirIdToEir[id] == address(0));

        // create new contract and store it
        EntityIdentityRecord eir = new EntityIdentityRecord(
            _identifiers,
            _content,
            _contentType,
            _hash,
            _signature,
            owner
        );

        eirIdToEir[id] = eir;
        eirIdList.push(id);

        LogNewEir(id, eir, _contentType);
        return true;
    }

    function revokeEir(bytes signature, bytes signer) public returns (bool) {
        EntityIdentityRecord eir = eirIdToEir[keccak256(signer)];
        require(address(eir) != address(0));
        SignatureVerifier signatureVerifier = signatureVerifiers[eir.getContentType()];
        require(address(signatureVerifier) != address(0));

        if (signatureVerifier.verifyDirectKeySignature(signature, signer)) {
            eir.revoke();
            LogRevokedEir(eir.getId());
            return true;
        }

        return false;
    }

    // Registers a new challenge record.
    function registerChallengeRecord(
        bytes32 _id,
        bytes32 _vaeId,
        bytes32 _challengeType,
        bytes _challenge,
        bytes32 _verifierEir,
        bytes32 _targetEir,
        bytes32 _hash,
        bytes _signature) public returns (bool)
    {

        // ensure CR hash is correct
        // TODO implement

        // ensure CR signature is correct
        // TODO implement

        // verifier exists
        EntityIdentityRecord verifier = getEir(_verifierEir);
        require(address(verifier) != address(0));

        // target exists
        EntityIdentityRecord target = getEir(_targetEir);
        require(address(target) != address(0));

        ValidationAuthenticationEntry vae = vaeIdToVae[_vaeId];
        var isInitialized = (address(vae)!=address(0));

        if (!isInitialized) {
            vae = new ValidationAuthenticationEntry(_vaeId, owner);
            vaeIdToVae[_vaeId] = vae;
            vaeIdList.push(_vaeId);
            LogNewVae(vae, _vaeId);
        }

        ChallengeRecord cr = new ChallengeRecord(
            _id,
            _vaeId,
            _challengeType,
            _challenge,
            verifier,
            target,
            _hash,
            _signature,
            owner
        );
        vae.addChallengeRecord(cr);

        LogNewChallengeRecord(
            cr,
            _challengeType,
            cr.getId(),
            cr.getVaeId()
        );
        return true;
    }

    // Registers a challenge response record.
    function registerChallengeResponse(
        bytes32 vaeId,
        bytes32 challengeId,
        bytes response,
        bytes32 hash,
        bytes signature) public returns (bool)
    {
        ValidationAuthenticationEntry vae = vaeIdToVae[vaeId];
        require(address(vae) != address(0));
        ChallengeResponseRecord rr = new ChallengeResponseRecord(
            vaeId,
            challengeId,
            response,
            hash,
            signature,
            owner
        );
        require(vae.addChallengeResponseRecord(rr));
        return true;
    }

    // Registers a challenge response signature record.
    function registerSignatureRecord(
        bytes32 _id,
        bytes32 _vaeId,
        bytes32 _responseRecordId,
        uint _expirationDate,
        bool _successful,
        bytes32[] _hash,
        bytes _signature) public returns (bool)
    {
        // check vae id. vae must exist and should be in correct status.
        ValidationAuthenticationEntry vae = vaeIdToVae[_vaeId];
        require(address(vae) != address(0));
        require(vae.getStatus() == 1);

        return true;
    }

    /**
    * @dev Registers signature verifier for some type of EIR. Registering EIR requires corresponding signature
    *      verifier.
    *
    * @param signatureVerifier signature verifier
    * @param eirType EIR type the signature verifier is implemented
    * @return true if signature verifier registration is successful.
    */
    function registerSignatureVerifier(SignatureVerifier signatureVerifier, bytes32 eirType) onlyOwner public returns (bool) {
        signatureVerifiers[eirType] = signatureVerifier;
        LogNewSignatureVerifier(signatureVerifier, eirType);
        return true;
    }

    // Returns the address of the EIR. This address can be used to access the actual EIR information.
    function getEir(bytes32 eirId) public view returns (EntityIdentityRecord) {
        return eirIdToEir[eirId];
    }

    function getVae(bytes32 vaeId) public view returns (ValidationAuthenticationEntry) {
        return vaeIdToVae[vaeId];
    }

    function getChallengeRecord(bytes32 id) public view returns (ChallengeRecord) {
        //TODO implement
        return ChallengeRecord(address(0));
    }

    function getEirCount() public view returns (uint) {
        return eirIdList.length;
    }

    function getVaeCount() public view returns (uint) {
        return vaeIdList.length;
    }

}
