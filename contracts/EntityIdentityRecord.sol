pragma solidity ^0.4.17;


import "./Identifiable.sol";
import "./signatures/SignatureVerifier.sol";
import "./utils/BytesUtils.sol";

/**
* @dev Entity Identity Record (EIR) contains information that links an entity to a certain
* identity and the corresponding public key or certificate. EIR is created during the key
* generation process and posted to the blockchain. 'content' field is used to store public
* key or certificate and it must be unique.
*/
contract EntityIdentityRecord is Identifiable {

    bytes32 private id;

    bytes32 private contentType;

    bytes private content;

    bytes32[] private identifiers;

    bool private revoked;

    uint private blockNumber;

    bytes32 private hash;

    bytes private signature;

    SignatureVerifier private signatureVerifier;

    event LogRevokedEir(bytes32 indexed id);

    function EntityIdentityRecord(
        bytes32[] _identifiers,
        bytes _content,
        bytes32 _contentType,
        bytes32 _hash,
        bytes _signature,
        SignatureVerifier _signatureVerifier,
        address _owner) {
        id = keccak256(_content);
        blockNumber = block.number;
        content = _content;
        contentType = _contentType;
        revoked = false;
        identifiers = _identifiers;
        hash = _hash;
        signature = _signature;
        signatureVerifier = _signatureVerifier;
        owner = _owner;
    }

    function getId() public view returns (bytes32) {
        return id;
    }

    function getBlockNumber() public view returns (uint) {
        return blockNumber;
    }

    function getContent() public view returns (bytes) {
        return content;
    }

    function getContentType() public view returns (bytes32) {
        return contentType;
    }

    function isRevoked() public view returns (bool) {
        return revoked;
    }

    function getIdentifiersCount() public view returns (uint) {
        return identifiers.length;
    }

    function getIdentifier(uint index) public view returns (bytes32) {
        return identifiers[index];
    }

    function getIdentifiers() public view returns (bytes32[]) {
        return identifiers;
    }

    function getHash() public view returns (bytes32) {
        return hash;
    }

    function getSignature() public view returns (bytes) {
        return signature;
    }

    function revoke(bytes revokingSignature) onlyCreator public returns(bool) {
        if(signatureVerifier.verify(BytesUtils.bytes32ToString(keccak256(id, contentType, content, identifiers, true)), revokingSignature, content)) {
            revoked = true;
            LogRevokedEir(id);
            return true;
        } else {
            return false;
        }
    }

    function verifySignature(string message, bytes signature) public returns(bool) {
        return signatureVerifier.verify(message, signature, content);
    }

}
