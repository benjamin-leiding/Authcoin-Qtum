pragma solidity ^0.4.17;


import "zeppelin/ownership/Ownable.sol";
import "./EntityIdentityRecord.sol";
import "./ChallengeRecord.sol";
import "./ChallengeResponseRecord.sol";
import "./ValidationAuthenticationEntry.sol";
import "./EntityIdentityRecordFactory.sol";
import "./PublicKeyEntityIdentityRecordFactory.sol";
import "./signatures/SignatureVerifier.sol";


// Main entry point for Authcoin protocol.
contract AuthCoin is Ownable {

    // stores EIR values (eir_id => EntityIdentityRecord)
    mapping (int => EntityIdentityRecord) private eirs;
    mapping (bytes32 => int) private contentHashToEirId;

    // stores the addresses of Entity Identity Records
    address[] private eirList;

    // stores challenge record values (cr_id => ChallengeRecord)
    mapping (int => ChallengeRecord) private challenges;

    // stores the values of ValidationAuthenticationEntry (vae_id => ValidationAuthenticationEntry)
    mapping (int => ValidationAuthenticationEntry) private vaes;

    // stores the addresses of ValidationAuthenticationEntry
    address[] private vaesList;

    // stores known EIR factory contracts (eir type =>  EntityIdentityRecordFactory)
    mapping (bytes32 => EntityIdentityRecordFactory) private factories;

    // stores known signature verifier contracts (eir type =>  SignatureVerifier)
    mapping (bytes32 => SignatureVerifier) private signatureVerifiers;

    // stores the addresses of EIR factory
    address[] private factoryList;

    event LogNewEir(EntityIdentityRecord a, bytes32 eirType, int id);
    event LogRevokedEir(int id);
    event LogNewChallengeRecord(ChallengeRecord cr, bytes32 challengeType, int id, int vaeId);
    event LogNewChallengeResponseRecord(ChallengeResponseRecord rr, int id, int vaeId, int crId);
    event LogNewVAE(address a, int id);
    event LogNewEirFactory(address a, bytes32 eirType);
    event LogNewSignatureVerifier(address a, bytes32 eirType);

    function AuthCoin() {
        // register default factory
        PublicKeyEntityIdentityRecordFactory f = new PublicKeyEntityIdentityRecordFactory();
        factories[bytes32("pub-key")] = f;
        factoryList.push(address(f));
    }

    // Registers a new EIR
    // TODO What kind of values are inside the identifiers in EIR? (e-mail, username, etc ?)
    // TODO May I assume that EIR identifiers are unique? (probably not?)
    // TODO Change the type of id 'parameter' to bytes32 or address?
    function registerEir(
        bytes32 eirType,
        int id,
        uint timestamp,
        bytes content,
        bool revoked,
        bytes32[] identifiers, // e-mail address, username, age, etc
        bytes32 hash,
        bytes signature) public returns (bool)
    {
        require(factories[eirType] != address(0));
        require(signatureVerifiers[eirType] != address(0));

        //TODO check id?
        EntityIdentityRecordFactory f = factories[eirType];
        EntityIdentityRecord eir = f.create(
            id,
            timestamp,
            content,
            revoked,
            identifiers,
            hash,
            signature,
            owner
        );

        // TODO May I assume that EIR ID is unique? (probably not?)
        eirs[id] = eir;
        contentHashToEirId[keccak256(content)] = id;
        eirList.push(address(eir));
        LogNewEir(eir, eirType, id);
        return true;
    }

    function revokeEir(bytes signature, bytes signer) public returns (bool) {
        EntityIdentityRecord eir = getEirByContentHash(keccak256(signer));
        require(address(eir) != address(0));
        SignatureVerifier signatureVerifier = signatureVerifiers[eir.getType()];
        require(address(signatureVerifier) != address(0));

        if(signatureVerifier.verifyDirectKeySignature(signature, signer)) {
            eir.revoke();
            LogRevokedEir(eir.getId());
            return true;
        }

        return false;
    }


    // Registers a new challenge record.
    function registerChallengeRecord(
        int id,
        int vaeId,
        uint timestamp,
        bytes32 challengeType,
        bytes32 challenge,
        int verifierEir,
        int targetEir,
        bytes32 hash,
        bytes signature) public returns (bool)
    {
        // TODO validate challenge type
        // TODO support of customizable challenges
        EntityIdentityRecord verifier = getEntityIdentityRecord(verifierEir);
        EntityIdentityRecord target = getEntityIdentityRecord(targetEir);

        ValidationAuthenticationEntry vae = vaes[vaeId];

        var isVerifier = (address(vae) == address(0));

        if (isVerifier) {
            // this is the first VAE with given identifier. create an entry for this vaeId
            vae = new ValidationAuthenticationEntry(vaeId, verifier, target, owner);
            vaes[vae.getVaeId()] = vae;
            vaesList.push(address(vae));
            LogNewVAE(vae, vaeId);
        }

        ChallengeRecord cr = new ChallengeRecord(
            id,
            vaeId,
            timestamp,
            challengeType,
            challenge,
            verifier,
            target,
            hash,
            signature,
            owner
        );
        challenges[cr.getId()] = cr;
        if (isVerifier) {
            require(vae.setChallenge(cr, 0));
        } else {
            require(vae.setChallenge(cr, 1));
        }
        LogNewChallengeRecord(
            cr,
            challengeType,
            cr.getId(),
            vae.getVaeId()
        );
        return true;
    }

    // Registers a challenge response record.
    function registerChallengeResponse(
        int vaeId,
        int challengeId,
        uint timestamp,
        bytes32 response,
        bytes32 hash,
        bytes signature) public returns (bool)
    {

        // check vae id. vae must exist and should be in correct status.
        ValidationAuthenticationEntry vae = vaes[vaeId];
        require(address(vae) != address(0));
        require(vae.getStatus() == 1);

        // check challenge record id. challengeId must be equal to verifier or target challenge id.
        ChallengeRecord verifierChallenge = vae.getVerifierChallengeRecord();
        ChallengeRecord targetChallenge = vae.getTargetChallengeRecord();

        require(verifierChallenge.getId() == challengeId || targetChallenge.getId() == challengeId);
        ChallengeResponseRecord rr = new ChallengeResponseRecord(
            vaeId,
            challengeId,
            timestamp,
            response,
            hash,
            signature,
            owner
        );

        require(vae.setChallengeResponseRecord(rr));
        return true;
    }

    // Registers a challenge response signature record.
    function registerSignatureRecord(
        int _id,
        int _vaeId,
        int _responseRecordId,
        uint _timestamp,
        uint _expirationDate,
        bool _successful,
        bytes32[] _hash,
        bytes _signature) public returns (bool)
    {

        // check vae id. vae must exist and should be in correct status.
        ValidationAuthenticationEntry vae = vaes[_vaeId];
        require(address(vae) != address(0));
        require(vae.getStatus() == 1);

        return true;
    }

    // Registers a new factory that can be used to create new EIRs. This method can be called
    // by the owner of the AuthCoin contract. Because of security reasons the factory contract
    // must be owned by the same address that owens the AuthCoin contract.
    function registerEirFactory(EntityIdentityRecordFactory factory, bytes32 eirType) onlyOwner public returns (bool) {
        require(factories[eirType] == address(0));
        factories[eirType] = factory;
        factoryList.push(address(factory));
        LogNewEirFactory(address(factory), eirType);
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
        LogNewSignatureVerifier(address(signatureVerifier), eirType);
        return true;
    }

    // Returns the address of the EIR. This address can be used to access the actual EIR information.
    function getEir(int eirId) public view returns (EntityIdentityRecord) {
        return eirs[eirId];
    }

    function getEirByContentHash(bytes32 contentHash) public view returns (EntityIdentityRecord) {
        return eirs[contentHashToEirId[contentHash]];
    }

    function getChallengeRecord(int id) public view returns (ChallengeRecord) {
        return challenges[id];
    }

    function getEntityIdentityRecord(int eirId) private view returns (EntityIdentityRecord) {
        EntityIdentityRecord eir = getEir(eirId);
        require(address(eir) != address(0));
        return eir;
    }

    function getEirFactoryCount() public view returns (uint) {
        return factoryList.length;
    }

    function getEirCount() public view returns (uint) {
        return eirList.length;
    }

    function getVAECount() public view returns (uint) {
        return vaesList.length;
    }

}
