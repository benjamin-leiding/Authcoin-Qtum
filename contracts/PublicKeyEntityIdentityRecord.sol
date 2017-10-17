pragma solidity ^0.4.15;


import "./EntityIdentityRecord.sol";
import "zeppelin/ownership/Ownable.sol";


// Entity Identity Record (EIR) contract that stores public keys.
contract PublicKeyEntityIdentityRecord is EntityIdentityRecord, Ownable {

    int private eirId;

    uint private timestamp;

    bytes private publicKey;

    bool private revoked;

    //bytes32 private eirHash;
    //bytes private signature;

    function PublicKeyEntityIdentityRecord(bytes _publicKey) {
        timestamp = block.timestamp;
        //TODO validate the key?
        publicKey = _publicKey;
    }

    function getTimestamp() public returns (uint) {
        return timestamp;
    }

    function isRevoked() public returns (bool) {
        return revoked;
    }

    function getOwner() public returns (address) {
        return owner;
    }

    function getType() public returns (bytes32) {
        return bytes32("pub-key");
    }

    function getData() public returns (bytes) {
        return publicKey;
    }

    function getId() public returns (int) {
        //TODO Maybe we can delete this function?
        return 1;
    }

}
