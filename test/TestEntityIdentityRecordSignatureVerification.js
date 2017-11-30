const util = require('ethereumjs-util');
var AuthCoin = artifacts.require("AuthCoin");
var ECSignatureVerifier = artifacts.require("signatures/ECSignatureVerifier");
var EntityIdentityRecord = artifacts.require("EntityIdentityRecord");

contract('AuthCoin & EntityIdentityRecord', function (accounts) {

    let authCoin

    // EIR values
    let identifiers = [web3.fromAscii("test@mail.com"), web3.fromAscii("John Doe")]
    let contentEcPubKey  = web3.toHex("0x192e545a9025d55e6088c55c7755ab3633e3e589")
    let idEc = web3.sha3(contentEcPubKey, {encoding: 'hex'})
    let contentTypeEc = util.bufferToHex(util.setLengthRight("ec", 32))
    let hashEc = web3.toHex("0x3365d64d81008b4f4b4399a7b05864c0dbb6a47ac82c34146f6847159a98d726")
    let ecEirSignature = web3.toHex("0x24f59e7d653d5f1e9f12fe4ee04f2720b708bb99f3e441b1661ea45951b2060368eaf1f19c3d18e067e332f8f8408d651f7257e5bf7f1a6f6e4a5ef5e225587101", 128)

    beforeEach("setup contract for all tests", async function () {
        authCoin = await AuthCoin.new(accounts[0])
        let ecSignatureVerifier = await ECSignatureVerifier.new(accounts[0])
        await authCoin.registerSignatureVerifier(ecSignatureVerifier.address, contentTypeEc)
    })

    it("should add EntityIdentityRecord with valid hash and signature", async function () {
        let success = false
        try {
            await authCoin.registerEir(contentEcPubKey, contentTypeEc, identifiers, hashEc, ecEirSignature)
            success = true
        } catch (error) {}
        assert.isOk(success)
    })

	it("should not add EntityIdentityRecord with invalid hash and valid signature", async function () {
        let success = false
        try {
            await authCoin.registerEir(contentEcPubKey, contentTypeEc, identifiers, web3.toHex("0x0"), ecEirSignature)
            success = true
        } catch (error) {}
        assert.isNotOk(success)
    })

    it("should not add EntityIdentityRecord with valid hash and invalid signature", async function () {
        let success = false
        try {
            await authCoin.registerEir(contentEcPubKey, contentTypeEc, identifiers, hashEc, web3.toHex("0x0"))
            success = true
        } catch (error) {}
        assert.isNotOk(success)
    })

})
