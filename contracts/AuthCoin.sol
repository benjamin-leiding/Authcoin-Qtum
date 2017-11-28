pragma solidity ^0.4.17;


import "zeppelin/ownership/Ownable.sol";
import "./EntityIdentityRecord.sol";
import "./ChallengeRecord.sol";
import "./ChallengeResponseRecord.sol";
import "./ValidationAuthenticationEntry.sol";
import "./signatures/SignatureVerifier.sol";
import "./utils/BytesUtils.sol";

/**
* @title AuthCoin
* @dev Main entry point for Authcoin protocol. Authcoin is an alternative approach to the commonly used public key infrastructures
* such as central authorities and the PGP web of trust. It combines a challenge response-based validation and authentication process
* for domains, certificates, email accounts and public keys with the advantages of a block chain-based storage system. Due to its
* transparent nature and public availability, it is possible to track the whole validation and authentication process history of each
* entity in the Authcoin system which makes it much more difficult to introduce sybil nodes and prevent such nodes from getting
* detected by genuine users.
*
* This contract can be used to register new entity identity records, create challenges and challenge responses and add challenge
* signature records. Also it supports revocation of entity identity and signature records.
*/
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

    // stores known signature verifier id's
    bytes32[] private verifierIdList;

    event LogNewEir(bytes32 id, EntityIdentityRecord eir, bytes32 contentType);

    event LogRevokedEir(bytes32 id);

    event LogNewChallengeRecord(ChallengeRecord cr, bytes32 challengeType, bytes32 id, bytes32 vaeId);

    event LogNewChallengeResponseRecord(ChallengeResponseRecord responseAddress, bytes32 challengeId);

    event LogNewVae(address vaeAddress, bytes32 id);

    event LogNewSignatureVerifier(SignatureVerifier a, bytes32 eirType);

    function AuthCoin() {
    }

    /**
    * @dev Adds new EIR to the blockchain.
    */
    function registerEir(
        bytes _content,
        bytes32 _contentType,
        bytes32[] _identifiers, // e-mail address, username, age, etc
        bytes32 _hash,
        bytes _signature) public returns (bool)
    {

        // ensure content type exists
        SignatureVerifier signatureVerifier = signatureVerifiers[_contentType];
        require(signatureVerifier != address(0));

        // ensure EIR hash is correct
        require(keccak256(_content, _contentType, _identifiers) == _hash);

        // ensure signature is correct
        require(signatureVerifier.verify(BytesUtils.bytes32ToString(_hash), _signature, _content));

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

    /**
    * @dev Adds a new challenge record to the blockchain.
    */
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

        // check VAE
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

    /**
    * @dev Registers a challenge response record.
    */
    function registerChallengeResponse(
        bytes32 _vaeId,
        bytes32 _challengeId,
        bytes _response,
        bytes32 _hash,
        bytes _signature) public returns (bool)
    {
        ValidationAuthenticationEntry vae = vaeIdToVae[_vaeId];
        require(address(vae) != address(0));
        ChallengeResponseRecord rr = new ChallengeResponseRecord(
            _vaeId,
            _challengeId,
            _response,
            _hash,
            _signature,
            owner
        );
        require(vae.addChallengeResponseRecord(rr));
        LogNewChallengeResponseRecord(rr, _challengeId);
        return true;
    }

    // Registers a challenge response signature record.
    function registerSignatureRecord(
        bytes32 _vaeId,
        bytes32 _challengeId,
        uint _expirationBlock,
        bool _successful,
        bytes32[] _hash,
        bytes _signature) public returns (bool)
    {
        // check vae id. vae must exist and should be in correct status.
        ValidationAuthenticationEntry vae = vaeIdToVae[_vaeId];
        require(address(vae) != address(0));
        //TODO implement
        return true;
    }

    /**
    * @dev Registers signature verifier for some type of EIR. Registering EIR requires corresponding signature
    * verifier. If signature verifier is present then it will be overridden. Only the owner of the AuthCoin
    * contract can add new signature verifiers.
    *
    * @param signatureVerifier signature verifier address
    * @param eirType EIR type the signature verifier is implemented for
    * @return true if signature verifier registration is successful
    */
    function registerSignatureVerifier(SignatureVerifier signatureVerifier, bytes32 eirType) onlyOwner public returns (bool) {
        if (address(signatureVerifiers[eirType]) == address(0)) {
            verifierIdList.push(eirType);
        }
        signatureVerifiers[eirType] = signatureVerifier;

        LogNewSignatureVerifier(signatureVerifier, eirType);
        return true;
    }

    /**
    * @dev Returns registered signature verifier address. If eir type is unknown then zero address will be returned.
    */
    function getSignatureVerifier(bytes32 eirType) public view returns (SignatureVerifier) {
        return signatureVerifiers[eirType];
    }

    /**
    * @dev Returns an array of registered signature verifier types.
    */
    function getSignatureVerifierTypes() public view returns (bytes32[]) {
        return verifierIdList;
    }

    /**
    * @dev Returns the address of the EIR given id. This address can be used to access the actual EIR. Zero address will be
    * returned if EIR id is unknown.
    */
    function getEir(bytes32 eirId) public view returns (EntityIdentityRecord) {
        return eirIdToEir[eirId];
    }

    /**
    * @dev Returns the validation and authentication entry for given VAE id. Zero address will be returned if VAE id is unknown.
    */
    function getVae(bytes32 vaeId) public view returns (ValidationAuthenticationEntry) {
        return vaeIdToVae[vaeId];
    }

    /**
    * @dev Returns the challenge record for given challenge id. Zero address will be returned if challenge id is unknown.
    */
    function getChallengeRecord(bytes32 challengeId) public view returns (ChallengeRecord) {
        //TODO implement
        return ChallengeRecord(address(0));
    }

    /**
    * @dev Returns the challenge response record for given challenge id. Zero address will be returned if challenge id is unknown.
    */
    function getChallengeResponseRecord(bytes32 challengeId) public view returns (ChallengeResponseRecord) {
        //TODO implement
        return ChallengeResponseRecord(address(0));
    }

    /**
    * @dev Returns the count of registered entity identity records
    */
    function getEirCount() public view returns (uint) {
        return eirIdList.length;
    }

    /**
    * @dev Returns the count of registered validation and authentication entries.
    */
    function getVaeCount() public view returns (uint) {
        return vaeIdList.length;
    }

}
