pragma solidity ^0.4.15;


import "zeppelin/ownership/Ownable.sol";
import "./EntityIdentityRecord.sol";
import "./ChallengeRecord.sol";
import "./ValidationAuthenticationEntry.sol";
import "./EntityIdentityRecordFactory.sol";
import "./PublicKeyEntityIdentityRecordFactory.sol";


// Main entry point for Authcoin protocol.
contract AuthCoin is Ownable {

    // stores EIR values (eir_id => EntityIdentityRecord)
    mapping (int => EntityIdentityRecord) private eirs;

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

    // stores the addresses of EIR factory
    address[] private factoryList;

    event Log_NewEir(EntityIdentityRecord a, bytes32 eirType, int id);

    event Log_NewChallengeRecord(ChallengeRecord cr, bytes32 challengeType, int id, int vaeId);

    event Log_NewVAE(address a, int id);

    event Log_NewEirFactory(address a, bytes32 eirType);

    function AuthCoin() {
        // register default factory
        PublicKeyEntityIdentityRecordFactory f = new PublicKeyEntityIdentityRecordFactory();
        factories[bytes32("pub-key")] = f;
        factoryList.push(address(f));
    }

    // Registers a new EIR
    // TODO What kind of values are inside the identifiers in EIR? (e-mail, username, etc ?)
    // TODO May I assume that EIR identifiers are unique? (probably not?)
    // TODO Change the type of id 'parameter' to bytes32?
    function registerEir(bytes32 eirType, int id, uint timestamp, bytes content, bool revoked, bytes32[] identifiers, bytes32 hash, bytes signature) public returns (bool) {
        require(factories[eirType] != address(0));
        //TODO check id?
        EntityIdentityRecordFactory f = factories[eirType];
        EntityIdentityRecord eir = f.create(id, timestamp, content, revoked, identifiers, hash, signature, owner);

        // TODO May I assume that EIR ID is unique? (probably not?)
        eirs[id] = eir;
        eirList.push(address(eir));
        Log_NewEir(eir, eirType, id);
        return true;
    }

    // Registers a new challenge record.
    function registerChallengeRecord(int id, int vaeId, uint timestamp, bytes32 challengeType, bytes32 challenge, int verifierEir, int targetEir, bytes32 hash, bytes signature) public returns (bool){
        // TODO validate challenge type
        // TODO support of customizable challenges
        EntityIdentityRecord verifier = getEntityIdentityRecord(verifierEir);
        EntityIdentityRecord target = getEntityIdentityRecord(targetEir);
        
        ValidationAuthenticationEntry vae = vaes[vaeId];

        var isVerifier = address(vae) == address(0);

        if (isVerifier) {
            // this is the first VAE with given identifier. create an entry for this vaeId
            vae = new ValidationAuthenticationEntry(vaeId, verifier, target, owner);

            vaes[vae.getVaeId()] = vae;
            vaesList.push(address(vae));
            Log_NewVAE(vae, vaeId);
        }

        ChallengeRecord cr = new ChallengeRecord(id, vaeId, timestamp, challengeType, challenge, verifier, target, hash, signature, owner);
        challenges[cr.getId()] = cr;
        if (isVerifier) {
            require(vae.setChallenge(cr, 0));
        }
        else {
            require(vae.setChallenge(cr, 1));
        }
        Log_NewChallengeRecord(cr, challengeType, cr.getId(), vae.getVaeId());
        return true;
    }

    // Registers a new factory that can be used to create new EIRs. This method can be called
    // by the owner of the AuthCoin contract. Because of security reasons the factory contract
    // must be owned by the same address that owens the AuthCoin contract.
    function registerEirFactory(EntityIdentityRecordFactory factory, bytes32 eirType) onlyOwner public returns (bool) {
        require(factories[eirType] == address(0));
        factories[eirType] = factory;
        factoryList.push(address(factory));
        Log_NewEirFactory(address(factory), eirType);
        return true;
    }

    // Returns the address of the EIR. This address can be used to access the actual EIR information.
    function getEir(int eirId) public returns (EntityIdentityRecord) {
        return eirs[eirId];
    }

    function getChallengeRecord(int id) public returns (ChallengeRecord) {
        return challenges[id];
    }

    function getEntityIdentityRecord(int eirId) private returns (EntityIdentityRecord) {
        EntityIdentityRecord eir = getEir(eirId);
        require(address(eir) != address(0));
        return eir;
    }

    function getEirFactoryCount() public returns (uint) {
        return factoryList.length;
    }

    function getEirCount() public returns (uint) {
        return eirList.length;
    }

    function getVAECount() public returns (uint) {
        return vaesList.length;
    }
}
