pragma solidity ^0.4.17;


// interface for different type of entity identity records
contract EntityIdentityRecord {

    function getId() public returns (int);

    function getTimestamp() public returns (uint);

    function isRevoked() public returns (bool);

    function getOwner() public returns (address);

    function getType() public returns (bytes32);

    function getContentType() public returns (bytes32);

    function getContent() public returns (bytes);

    function getIdentifier(uint index) public returns (bytes32);

    function getIdentifiersCount() public returns (uint);

    function setRevoked(bool isRevoked) public;

    //function getHash() public returns(bytes32);
    //function getSignature() public returns(bytes32);
}
