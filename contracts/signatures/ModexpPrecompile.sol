pragma solidity ^0.4.17;

import "../utils/BytesUtils.sol";

library ModexpPrecompile {
    using BytesUtils for *;

    /**
    * @dev  Native contract at address 0x00......05, add a precompile that expects input in the following format:
    *       <length of BASE> <BASE> <length of EXPONENT> <EXPONENT> <length of MODULUS> <MODULUS>
    *
    *       The gas cost would be 32**2 * 32 / 20 = 1638 gas (note that this roughly equals the cost of using the EXP
    *       opcode to compute a 32-byte exponent). A 4096-bit RSA exponentiation would cost 256**2 * 256 / 20 = 838860
    *       gas in the worst case, though RSA verification in practice usually uses an exponent of 3 or 65537, which
    *       would reduce the gas consumption to 3276 or 6553, respectively.
    *
    *
    * @param base Base.
    * @param exponent Exponent.
    * @param modulus Modulus.
    */
    function modexp(bytes base, uint exponent, bytes modulus) internal view returns (bool success, bytes output) {
        uint baseLength = base.length;
        uint modulusLength = modulus.length;

        uint size = (32 * 3) + baseLength + 32 + modulusLength;
        bytes memory input = new bytes(size);
        output = new bytes(modulusLength);

        assembly {
            mstore(add(input, 32), baseLength)
            mstore(add(input, 64), 32)
            mstore(add(input, 96), modulusLength)
            mstore(add(input, add(128, baseLength)), exponent)
        }

        BytesUtils.memcopy(base, 0, input, 96, baseLength);
        BytesUtils.memcopy(modulus, 0, input, 96 + baseLength + 32, modulusLength);

        assembly {
            // staticcall to bigint_modexp (bigint modular exponentiation) precompiled contract at address 0x0000....05. EIP-198.
            success := staticcall(gas(), 5, add(input, 32), size, add(output, 32), modulusLength)
        }
    }
}