pragma solidity ^0.4.17;

import "../utils/BytesUtils.sol";

library ECVerify {

    using BytesUtils for *;

    /**
     * @dev Verifies input hash aginst signature.
     *
     * @param msgHash keccak256 hash of message contained in signature
     * @param sig signature to recover
     * @param signer public key address
     * @return True if the input hash is equal to the recovered signature data.
     */
    function verifySignature(bytes32 msgHash, bytes sig, address signer) internal pure returns (bool) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        if (sig.length != 65)
            return false;

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        if (v < 27)
            v += 27;

        if (v != 27 && v != 28)
            return false;

        return signer ==  ecrecover(msgHash, v, r, s);
    }

    /**
     * @dev Verifies input hash aginst signature.
     *
     * @param msgHash keccak256 hash of message contained in signature
     * @param sig signature to recover
     * @param signer public key address
     * @return True if the input hash is equal to the recovered signature data.
     */
    function verifySignature(bytes32 msgHash, bytes sig, bytes signer) internal pure returns (bool) {
        return verifySignature(msgHash, sig, BytesUtils.bytesToAddress(signer));
    }

    /**
     * @dev Verifies direct key signature.
     *
     * @param signature signature to verify
     * @param signer public key address.
     * @return True if the signature contains the public key address the signature was signed with.
     */
    function verifyDirectKeySignature(bytes signature, bytes signer) internal pure returns (bool) {
        bytes32 publicKeyAddressHash = keccak256(BytesUtils.bytesToString(signer));
        return verifySignature(publicKeyAddressHash, signature, signer);
    }
}