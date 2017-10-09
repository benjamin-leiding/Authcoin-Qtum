pragma solidity ^0.4.15;


// interface for different type of entity identity records
contract EntityIdentityRecord {

    function getTimestamp() public returns (uint);

    function isRevoked() public returns (bool);

    function getOwner() public returns (address);

    function getId() public returns (int);

    function getType() public returns (bytes32);

    function getData() public returns (bytes);

    //function getEirId() public returns (int);
    //function getHash() public returns(bytes32);
    //function getSignature() public returns(bytes32);
}
