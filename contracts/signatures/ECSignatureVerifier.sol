pragma solidity ^0.4.17;

import "./SignatureVerifier.sol";
import "../utils/BytesUtils.sol";

contract ECSignatureVerifier is SignatureVerifier {

    using BytesUtils for *;

    function verifySignature(bytes32 messageHash, bytes signature, address signer) private view returns (bool) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        if (signature.length != 65)
            return false;

        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }

        if (v < 27)
            v += 27;

        if (v != 27 && v != 28)
            return false;

        return signer ==  ecrecover(messageHash, v, r, s);
    }

    function verify(bytes message, bytes signature, bytes signer) public view returns (bool) {
        bytes32 messageHash = keccak256(BytesUtils.bytesToString(message));
        return verifySignature(messageHash, signature, BytesUtils.bytesToAddress(signer));
    }

    function verifyDirectKeySignature(bytes signature, bytes signer) public view returns (bool) {
        return verify(signer, signature, signer);
    }

}