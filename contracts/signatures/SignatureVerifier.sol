pragma solidity ^0.4.17;


contract SignatureVerifier {

    /**
    * @dev Verifies signature.
    *
    * @param message message to verify against signature
    * @param signature signature of a message
    * @param signer signer of signature
    * @return true if message hash is contained in signature.
    */
    function verify(bytes message, bytes signature, bytes signer) public view returns (bool);

    /**
    * @dev Verifies signature.
    *
    * @param signature signature of a message
    * @param signer signer of signature
    * @return true if hash of signer is contained in signature.
    */
    function verifySelfSignature(bytes signature, bytes signer) public view returns (bool);

}