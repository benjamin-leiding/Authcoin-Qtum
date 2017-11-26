pragma solidity ^0.4.17;


import "contracts/signatures/SignatureVerifier.sol";


contract DummyVerifier is SignatureVerifier {

    function verify(bytes message, bytes signature, bytes signer) public view returns (bool) {
        return true;
    }

    function verifyDirectKeySignature(bytes signature, bytes signer) public view returns (bool) {
        return true;
    }

}
