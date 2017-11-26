const util = require('ethereumjs-util');
var AuthCoin = artifacts.require("AuthCoin");
var ECSignatureVerifier = artifacts.require("signatures/ECSignatureVerifier");
var RsaSignatureVerifier = artifacts.require("signatures/RsaSignatureVerifier");
var EntityIdentityRecord = artifacts.require("EntityIdentityRecord");

contract('AuthCoin & ChallengeRecord', function (accounts) {

    let authCoin

    // EIR values
    let identifiers = [web3.fromAscii("test@mail.com"), web3.fromAscii("John Doe")]
    let contentRsaPubKey = web3.toHex("0x9ffabf3dd8add28b8b08ee6f868ec0628081f6acf8a340da4e5b4624959f1e61fb5cdccf25e25c582eca14c200e57443933819a81b7b1d35165c9d869fec9135")
    let contentEcPubKey  = web3.toHex("0xfdaa33846e677adac0a66ba60029319698e58623")
    let idEc = web3.sha3(contentEcPubKey, {encoding: 'hex'})
    let idRsa = web3.sha3(contentRsaPubKey, {encoding: 'hex'})
    let hash = web3.fromAscii("hash", 32)
    let contentTypeRsa = util.bufferToHex(util.setLengthRight("rsa", 32))
    let contentTypeEc = util.bufferToHex(util.setLengthRight("ec", 32))
    let eirSignature = web3.fromAscii("signature", 128)

    before("setup contract for all tests", async function () {
        authCoin = await AuthCoin.new(accounts[0])
        let ecSignatureVerifier = await ECSignatureVerifier.new(accounts[0])
        let rsaSignatureVerifier = await RsaSignatureVerifier.new(accounts[0])
        await authCoin.registerSignatureVerifier(ecSignatureVerifier.address, contentTypeEc)
        await authCoin.registerSignatureVerifier(rsaSignatureVerifier.address, contentTypeRsa)
        await authCoin.registerEir(contentRsaPubKey, contentTypeRsa, identifiers, hash, eirSignature)
        await authCoin.registerEir(contentEcPubKey, contentTypeEc, identifiers, hash, eirSignature)
    })

    it("should not revoke EIR with RSA content type and invalid revocation signature", async function () {
        let directKeyRevocationSignature = web3.toHex("0x216c3a465148643dc7eeb38bd79c5453fc98f02fc80a93e39b4f957c0f00bcc3c00af2eeaf076f9be066778bca05a71d5147aca2f6dcb8b00000000000000000", 128)
        await authCoin.revokeEir(directKeyRevocationSignature, contentRsaPubKey);
        let eir = EntityIdentityRecord.at(await authCoin.getEir(idRsa))
        assert.isFalse(await eir.isRevoked())
    })

    it("should not revoke EIR with EC content type and invalid revocation signature", async function () {
        let directKeyRevocationSignature = web3.toHex("0x27dd01b872b09b6007e5f401494caeb75fbc21e61836b1f9d875d07fc468dcb825bf76eaa6cf7090c6a3e365c3e7b1f1bf7a67707f6c0f90000000000000000000", 128)
        await authCoin.revokeEir(directKeyRevocationSignature, contentEcPubKey);
        let eir = EntityIdentityRecord.at(await authCoin.getEir(idEc))
        assert.isFalse(await eir.isRevoked())
    })

    it("should revoke EIR with RSA content type and valid revocation signature", async function () {
        let directKeyRevocationSignature = web3.toHex("0x216c3a465148643dc7eeb38bd79c5453fc98f02fc80a93e39b4f957c0f00bcc3c00af2eeaf076f9be066778bca05a71d5147aca2f6dcb8b97b88f2c647a422f9", 128)
        await authCoin.revokeEir(directKeyRevocationSignature, contentRsaPubKey);
        let eir = EntityIdentityRecord.at(await authCoin.getEir(idRsa))
        assert.isTrue(await eir.isRevoked())
    })

    it("should revoke EIR with EC content type and valid revocation signature", async function () {
        let directKeyRevocationSignature = web3.toHex("0x27dd01b872b09b6007e5f401494caeb75fbc21e61836b1f9d875d07fc468dcb825bf76eaa6cf7090c6a3e365c3e7b1f1bf7a67707f6c0f92dd3e3aa9ae9e7a3b00", 128)
        await authCoin.revokeEir(directKeyRevocationSignature, contentEcPubKey);
        let eir = EntityIdentityRecord.at(await authCoin.getEir(idEc))
        assert.isTrue(await eir.isRevoked())
    })

})
