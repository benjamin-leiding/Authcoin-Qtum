const util = require('ethereumjs-util');
var AuthCoin = artifacts.require("AuthCoin");
var ECSignatureVerifier = artifacts.require("signatures/ECSignatureVerifier");
var EntityIdentityRecord = artifacts.require("EntityIdentityRecord");

contract('AuthCoin & ChallengeResponseRecord', function (accounts) {

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
    let challengeId1 = web3.fromAscii("challenge1")
    let challengeId2 = web3.fromAscii("challenge2")
    let vaeId = util.bufferToHex(util.setLengthRight("vae1", 32))
    let challengeType = web3.fromAscii("signing challenge")
    let challenge = web3.fromAscii("sign value 'HELLO'", 128)
    let hashChallenge1 = web3.toHex("0x0e4302d84aabc8a965883a5a97dfa6ba95c8970bfa64bfccc2369495bc5e14bc")
    let hashChallenge2 = web3.toHex("0x8f14a58485f3dbdaa1679e2e8a9b9ee61b8b9f1c4ef94542b8fb47c6e4ec5879")
    let challengeSignature1 = web3.toHex("0x385fb6c60d61d78873c9f2817660b5d7d5f363a18fa18a15f0a6618104666f6a4550bd267755c362222848b383a109ff33c36dfa3eab98d696f8af3a23d6e47200", 128)
    let challengeSignature2 = web3.toHex("0xe06771999836e2b5c35a9aa282d8892901f0522b7fe4f9dbd71513e81412e34f06761becd5b609504dcbd2cf3ce26e5366e158c1842a668304232c9f0e96980800", 128)

    // CRR
    let challengeResponseRecordContent = web3.fromAscii("challengeresponse", 128)
    let callengeResponseRecordHash = web3.toHex("0xba8077882ce7b9fe1c17c07cdd822e6e77d0ce5bdc46a2bbe1dc8646d37c2c3d")
    let challengeResponseRecordSignature = web3.toHex("0x256623882511280ab1423348b47298698dc5e88a0aa1765e550883dee722f1783bd86dd15f493e336f824b66998ba8c8c90c56f7a42615b9d1f02910083260ce00", 128)

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
        await authCoin.registerChallengeRecord(challengeId1, vaeId, challengeType, challenge, verifierEirId, targetEirId, hashChallenge1, challengeSignature1)
        await authCoin.registerChallengeRecord(challengeId2, vaeId, challengeType, challenge, targetEirId, verifierEirId, hashChallenge2, challengeSignature2)
    })

    it("should add ChallengeResponseRecord with valid hash and signature by verifier EIR", async function () {
        let success = false
        try {
            await authCoin.registerChallengeResponse(vaeId, challengeId1, challengeResponseRecordContent, callengeResponseRecordHash, challengeResponseRecordSignature)
            success = true
        } catch (error) {}
        assert.isOk(success)
    })

    it("should not add ChallengeResponseRecord with invalid hash and signature by verifier EIR", async function () {
        let success = false
        try {
            await authCoin.registerChallengeResponse(vaeId, challengeId1, challengeResponseRecordContent, web3.toHex("0x0"), challengeResponseRecordSignature)
            success = true
        } catch (error) {}
        assert.isNotOk(success)
    })

    it("should not add ChallengeResponseRecord with valid hash and invalid signature by verifier EIR", async function () {
        let success = false
        try {
            await authCoin.registerChallengeResponse(vaeId, challengeId1, challengeResponseRecordContent, callengeResponseRecordHash, web3.toHex("0x0"))
            success = true
        } catch (error) {}
        assert.isNotOk(success)
    })
})
