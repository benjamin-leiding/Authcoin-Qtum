const util = require('ethereumjs-util');
var AuthCoin = artifacts.require("AuthCoin");
var ECSignatureVerifier = artifacts.require("signatures/ECSignatureVerifier");
var RsaSignatureVerifier = artifacts.require("signatures/RsaSignatureVerifier");
var EntityIdentityRecord = artifacts.require("EntityIdentityRecord");

contract('Revoke EIR', function (accounts) {

    let authCoin

    // EIR values
    let identifiers = [web3.fromAscii("test@mail.com"), web3.fromAscii("John Doe")]
    let contentRsaPubKey = web3.toHex("0x96b8fb1151ed0d0dfbcdbf4d2487d68d9a6b3f5249e4fe054a7f52a1e0e9c21ce09e9e41efb5bcfe6767d93f652129ca3163314c83eeff1b317a420ae469462f")
    let contentEcPubKey  = web3.toHex("0x192e545a9025d55e6088c55c7755ab3633e3e589")
    let idRsa = web3.sha3(contentRsaPubKey, {encoding: 'hex'})
    let idEc = web3.sha3(contentEcPubKey, {encoding: 'hex'})
    let contentTypeRsa = util.bufferToHex(util.setLengthRight("rsa", 32))
    let contentTypeEc = util.bufferToHex(util.setLengthRight("ec", 32))
    let hashRsa = web3.toHex("0x5874f34935bfeea6079953d667b89f971f0127bdaf4bffc69d197c050a8b849e")
    let hashEc = web3.toHex("0x3365d64d81008b4f4b4399a7b05864c0dbb6a47ac82c34146f6847159a98d726")
    let rsaEirSignature = web3.toHex("0x01eef652c011db5bdf671a13742a38584295e3aae19e453eb187cbc15cbc0f09f70230d76126033fd5b025884851c3a96a9b9851abbe0e1eb91533caff528e16", 128)
    let ecEirSignature = web3.toHex("0x24f59e7d653d5f1e9f12fe4ee04f2720b708bb99f3e441b1661ea45951b2060368eaf1f19c3d18e067e332f8f8408d651f7257e5bf7f1a6f6e4a5ef5e225587101", 128)

    before("setup contract for all tests", async function () {
        authCoin = await AuthCoin.new(accounts[0])
        let ecSignatureVerifier = await ECSignatureVerifier.new(accounts[0])
        let rsaSignatureVerifier = await RsaSignatureVerifier.new(accounts[0])
        await authCoin.registerSignatureVerifier(ecSignatureVerifier.address, contentTypeEc)
        await authCoin.registerSignatureVerifier(rsaSignatureVerifier.address, contentTypeRsa)
        await authCoin.registerEir(contentRsaPubKey, contentTypeRsa, identifiers, hashRsa, rsaEirSignature)
        await authCoin.registerEir(contentEcPubKey, contentTypeEc, identifiers, hashEc, ecEirSignature)
    })

    it("should not revoke EIR with RSA content type and invalid revocation signature", async function () {
        let directKeyRevocationSignature = web3.toHex("0x216c3a465148643dc7eeb38bd79c5453fc98f02fc80a93e39b4f957c0f00bcc3c00af2eeaf076f9be066778bca05a71d5147aca2f6dcb8b00000000000000000", 128)
        await authCoin.revokeEir(idRsa, directKeyRevocationSignature);
        let eir = EntityIdentityRecord.at(await authCoin.getEir(idRsa))
        assert.isFalse(await eir.isRevoked())
    })

    it("should not revoke EIR with EC content type and invalid revocation signature", async function () {
        let directKeyRevocationSignature = web3.toHex("0x27dd01b872b09b6007e5f401494caeb75fbc21e61836b1f9d875d07fc468dcb825bf76eaa6cf7090c6a3e365c3e7b1f1bf7a67707f6c0f90000000000000000000", 128)
        await authCoin.revokeEir(idEc, directKeyRevocationSignature);
        let eir = EntityIdentityRecord.at(await authCoin.getEir(idEc))
        assert.isFalse(await eir.isRevoked())
    })

    it("should revoke EIR with RSA content type and valid revocation signature", async function () {
        let directKeyRevocationSignature = web3.toHex("0x43c476c6ba4b3ea090bfaece16dac0036df89731828485674ee4a6deae672101b1862694093482e3155347c74d23dd94939b913ce75d7bff3719634935b30faa", 128)
        await authCoin.revokeEir(idRsa, directKeyRevocationSignature);
        let eir = EntityIdentityRecord.at(await authCoin.getEir(idRsa))
        assert.isTrue(await eir.isRevoked())
    })

    it("should revoke EIR with EC content type and valid revocation signature", async function () {
        let directKeyRevocationSignature = web3.toHex("0x55529cff5ce9bf402aefe80de05cd76254f748d9eec09550cb82dbfecc49889e6fd8d08076bc505990f9a6721a8f998a5af3fb116316660ff9da8f0b616da9cd01", 128)
        await authCoin.revokeEir(idEc, directKeyRevocationSignature);
        let eir = EntityIdentityRecord.at(await authCoin.getEir(idEc))
        assert.isTrue(await eir.isRevoked())
    })

})
