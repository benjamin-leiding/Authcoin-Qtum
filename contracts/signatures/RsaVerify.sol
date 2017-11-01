pragma solidity ^0.4.17;

import "./ModexpPrecompile.sol";

library RsaVerify {
    using ModexpPrecompile for *;

    /**
     * @dev Verifies input data aginst RSA signature.
     *
     * @param paddedData Padded data to verify against signature.
     * @param N The RSA public modulus.
     * @param e The RSA public exponent.
     * @param S The signature to recover.
     * @return True if the input data is equal to the recovered signature data.
     */
    function rsaverify(bytes paddedData, bytes N, uint e, bytes S) internal view returns (bool) {
        var (modexpSuccess, modexpOutput) = ModexpPrecompile.modexp(S, e, N);
        // NOTE: keccak256 is the cheapest for equality comparison
        return modexpSuccess == true && keccak256(modexpOutput) == keccak256(paddedData);
    }
}