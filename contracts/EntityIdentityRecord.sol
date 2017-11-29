pragma solidity ^0.4.17;


import "./signatures/SignatureVerifier.sol";
import "./utils/BytesUtils.sol";


/**
* @dev Entity Identity Record (EIR) contains information that links an entity to a certain
* identity and the corresponding public key or certificate. EIR is created during the key
* generation process and posted to the blockchain. 'content' field is used to store public
* key or certificate and it must be unique.
*/
contract EntityIdentityRecord {

    bytes32 private id;

    bytes32 private contentType;

    bytes private content;

    bytes32[] private identifiers;

    bool private revoked;

    uint private blocNumber;

    bytes private signature;

    SignatureVerifier private signatureVerifier;

    address private contractCreator;

    address private contractOwner;

    modifier onlyContractOwner() {
        if (msg.sender == contractOwner)
        _;
    }

    modifier onlyContractCreator() {
        if (msg.sender == contractCreator)
        _;
    }

    event LogRevokedEir(bytes32 indexed id);

    function EntityIdentityRecord(
        bytes32[] _identifiers,
        bytes _content,
        bytes32 _contentType,
        bytes32 _hash,
        bytes _signature,
        SignatureVerifier _signatureVerifier,
        address _contractCreator,
        address _contractOwner) {
        id = keccak256(_content);
        blocNumber = block.number;
        content = _content;
        contentType = _contentType;
        revoked = false;
        identifiers = _identifiers;
        signature = _signature;
        signatureVerifier = _signatureVerifier;
        contractCreator = _contractCreator;
        contractOwner = _contractOwner;

        // ensure EIR hash is correct
        require(getHash() == _hash);

        // ensure signature is correct
        require(signatureVerifier.verify(BytesUtils.bytes32ToString(_hash), _signature, _content));
    }

    function getId() public view returns (bytes32) {
        return id;
    }

    function getBlocNumber() public view returns (uint) {
        return blocNumber;
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

    function getCreator() public view returns (address) {
        return contractCreator;
    }

    function getHash() public view returns (bytes32) {
        return keccak256(id, contentType, content, identifiers, revoked);
    }

    function getSignature() public view returns (bytes) {
        return signature;
    }

    // TODO: fix tests when adding onlyContractOwner modifier
    function revoke(bytes revokingSignature) public returns(bool) {
        if(signatureVerifier.verify(BytesUtils.bytes32ToString(keccak256(id, contentType, content, identifiers, true)), revokingSignature, content)) {
            revoked = true;
            LogRevokedEir(id);
            return true;
        } else {
            return false;
        }
    }

}
