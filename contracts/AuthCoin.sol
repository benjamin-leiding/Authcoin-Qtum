pragma solidity ^0.4.15;


import "zeppelin/ownership/Ownable.sol";
import "./EntityIdentityRecord.sol";
import "./EntityIdentityRecordFactory.sol";
import "./PublicKeyEntityIdentityRecordFactory.sol";


// Main entry point for Authcoin protocol.
contract AuthCoin is Ownable {

    // stores EIR values (eir_id => EntityIdentityRecord)
    mapping (int => EntityIdentityRecord) private eirs;

    // stores the addresses of Entity Identity Records
    address[] private eirList;

    // stores known EIR factory contracts (eir type =>  EntityIdentityRecordFactory)
    mapping (bytes32 => EntityIdentityRecordFactory) private factories;

    // stores the addresses of EIR factory
    address[] private factoryList;

    event LogNewEir(EntityIdentityRecord a, bytes32 eirType);
    event LogNewEirFactory(address a, bytes32 eirType);

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
    function registerEir(
        bytes32 eirType,
        int id,
        uint timestamp,
        bytes content,
        bool revoked,
        bytes32[] identifiers,
        bytes32 hash,
        bytes signature) public returns (bool)
    {
        require(factories[eirType] != address(0));
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
        eirList.push(address(eir));
        LogNewEir(eir, eirType);
        return true;
    }

    // Registers a new factory that can be used to create new EIR. This method can be called
    // by the owner of the AuthCoin contract. Because of security reasons the factory contract
    // must be owned by the same address that owens the AuthCoin contract.
    function registerEirFactory(EntityIdentityRecordFactory factory, bytes32 eirType) onlyOwner returns (bool) {
        require(factories[eirType] == address(0));
        factories[eirType] = factory;
        factoryList.push(address(factory));
        LogNewEirFactory(address(factory), eirType);
        return true;
    }

    // Returns the address of the EIR. This address can be used to access the actual EIR information.
    function getEir(int eirId) public returns (address) {
        return eirs[eirId];
    }

    function getEirFactoryCount() public returns (uint) {
        return factoryList.length;
    }

    function getEirCount() public returns (uint) {
        return eirList.length;
    }

}
