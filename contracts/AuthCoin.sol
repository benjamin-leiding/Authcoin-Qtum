pragma solidity ^0.4.15;


import "./Ownable.sol";
import "./EntityIdentityRecord.sol";
import "./EntityIdentityRecordFactory.sol";
import "./PublicKeyEntityIdentityRecordFactory.sol";


// Main entry point for Authcoin.
contract AuthCoin is Ownable {

    // stores known EIR factory contracts (eir type =>  EntityIdentityRecordFactory)
    mapping (bytes32 => EntityIdentityRecordFactory) private factories;

    // stores the addressed of EIR factory
    address[] private factoryList;

    // stores EIR values (identity => EntityIdentityRecord)
    mapping (bytes32 => EntityIdentityRecord) private eirs;

    // stores the addressed of Entity Identity Records
    address[] private eirList;

    event NewEir(EntityIdentityRecord a, bytes32 eirType);

    event NewEirFactory(address a, bytes32 eirType);

    function AuthCoin() {
        // register default factory
        PublicKeyEntityIdentityRecordFactory f = new PublicKeyEntityIdentityRecordFactory();
        factories[bytes32("pub-key")] = f;
        factoryList.push(address(f));
    }

    // Registers a new EIR.
    function registerEir(bytes32 eirType, bytes data, bytes32 identity) returns (bool) {
        require(factories[eirType] != address(0));
        EntityIdentityRecordFactory f = factories[eirType];
        EntityIdentityRecord eir = f.create(data);

        eirs[identity] = eir;
        eirList.push(address(eir));
        NewEir(eir, eirType);
        return true;
    }

    // Registers a new factory that can be used to create a new EIR. This method can be called
    // by the owner of the AuthCoinContract.
    function registerEirFactory(EntityIdentityRecordFactory factory, bytes32 eirType) returns (bool) {
        require(factories[eirType] == address(0));
        factories[eirType] = factory;
        factoryList.push(address(factory));
        NewEirFactory(address(factory), eirType);
        return true;
    }

    function getEirFactoryCount() returns (uint count) {
        return factoryList.length;
    }

    function getEirCount() returns (uint count) {
        return eirList.length;
    }

}
