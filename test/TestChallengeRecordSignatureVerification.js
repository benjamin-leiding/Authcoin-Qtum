const util = require('ethereumjs-util');
var AuthCoin = artifacts.require("AuthCoin");
var ECSignatureVerifier = artifacts.require("signatures/ECSignatureVerifier");
var EntityIdentityRecord = artifacts.require("EntityIdentityRecord");

contract('AuthCoin & ChallengeRecord', function (accounts) {

 let authCoin
    let eir1
    let eir2
    let verifierEirId
    let targetEirId

    // EIR values
    let identifiers = [web3.fromAscii("test@mail.com"), web3.fromAscii("John Doe")]
    let contentType = util.bufferToHex(util.setLengthRight("ec", 32))
    let eirContent1  = web3.toHex("0x192e545a9025d55e6088c55c7755ab3633e3e589")
    let eirContent2  = web3.toHex("0x81970d1d41c548cc4b83c7cb5d7d7e6aecdcb1f5")
    let eirId1 = web3.sha3(eirContent1, {encoding: 'hex'})
    let eirId2 = web3.sha3(eirContent2, {encoding: 'hex'})
    let eirHash1 = web3.toHex("0x3365d64d81008b4f4b4399a7b05864c0dbb6a47ac82c34146f6847159a98d726")
    let eirHash2 = web3.toHex("0xeb5ed83a92d2c0e8651b2e56c3bce04475c2db646d96439cc13d9ed8f69cba8b")
    let eirSignature1 = web3.toHex("0x24f59e7d653d5f1e9f12fe4ee04f2720b708bb99f3e441b1661ea45951b2060368eaf1f19c3d18e067e332f8f8408d651f7257e5bf7f1a6f6e4a5ef5e225587101", 128)
    let eirSignature2 = web3.toHex("0xcc63444aeeaf217fe8323e55d176577994cfc6324f13703cfca525c9960f163f3217520597a54977c73cd3e76c9b3e3165ac5f7c0870d37ae1ddcc7627b0029801", 128)

    // CR values
    let challengeId = web3.fromAscii("challenge1")
    let vaeId = util.bufferToHex(util.setLengthRight("vae1", 32))
    let challengeType = web3.fromAscii("signing challenge")
    let challenge = web3.fromAscii("sign value 'HELLO'", 128)
    let challengeHash = web3.toHex("0x0e4302d84aabc8a965883a5a97dfa6ba95c8970bfa64bfccc2369495bc5e14bc")
    let challengeSignature = web3.toHex("0x385fb6c60d61d78873c9f2817660b5d7d5f363a18fa18a15f0a6618104666f6a4550bd267755c362222848b383a109ff33c36dfa3eab98d696f8af3a23d6e47200", 128)

    beforeEach('setup contract for test', async function () {
        authCoin = await AuthCoin.new(accounts[0])
        let ecSignatureVerifier = await ECSignatureVerifier.new(accounts[0])
        await authCoin.registerSignatureVerifier(ecSignatureVerifier.address, contentType)
        await authCoin.registerEir(eirContent1, contentType, identifiers, eirHash1, eirSignature1)
        await authCoin.registerEir(eirContent2, contentType, identifiers, eirHash2, eirSignature2)
        eir1 = EntityIdentityRecord.at(await authCoin.getEir(eirId1))
        eir2 = EntityIdentityRecord.at(await authCoin.getEir(eirId2))
        verifierEirId = await eir1.getId()
        targetEirId = await eir2.getId()
    })

    it("should add ChallengeRecord with valid hash and signature by verifier EIR", async function () {
        let success = false
        try {
            await authCoin.registerChallengeRecord(challengeId, vaeId, challengeType, challenge, verifierEirId, targetEirId, challengeHash, challengeSignature)
            success = true
        } catch (error) {}
        assert.isOk(success)
    })

    it("should not add ChallengeRecord with valid hash and valid signature by target EIR", async function () {
        let success = false
        try {
            await authCoin.registerChallengeRecord(challengeId, vaeId, challengeType, challenge, targetEirId, verifierEirId, challengeHash, challengeSignature)
            success = true
        } catch (error) {}
        assert.isNotOk(success)
    })

	it("should not add ChallengeRecord with invalid hash and valid signature", async function () {
        let success = false
        try {
            await authCoin.registerChallengeRecord(challengeId, vaeId, challengeType, challenge, verifierEirId, targetEirId, web3.toHex("0x0"), challengeSignature)
            success = true
        } catch (error) {}
        assert.isNotOk(success)
    })

    it("should not add ChallengeRecord with valid hash and invalid signature", async function () {
        let success = false
        try {
            await authCoin.registerChallengeRecord(challengeId, vaeId, challengeType, challenge, verifierEirId, targetEirId, challengeHash, web3.toHex("0x0"))
            success = true
        } catch (error) {}
        assert.isNotOk(success)
    })

})
