const util = require('ethereumjs-util');
var AuthCoin = artifacts.require("AuthCoin");
var DummyVerifier = artifacts.require("signatures/DummyVerifier");
var EntityIdentityRecord = artifacts.require("EntityIdentityRecord");
var ValidationAuthenticationEntry = artifacts.require("ValidationAuthenticationEntry");

contract('AuthCoin & ChallengeSignatureRecord', function (accounts) {

    let authCoin
    let eir1
    let eir2
    let verifierEirId
    let targetEirId

    // EIR values
    let identifiers = [web3.fromAscii("test@mail.com"), web3.fromAscii("John Doe")]
    let content = web3.fromAscii("content")
    let content2 = web3.fromAscii("content2")
    let eirId1 = web3.sha3(content, {encoding: 'hex'})
    let eirId2 = web3.sha3(content2, {encoding: 'hex'})
    let contentType = util.bufferToHex(util.setLengthRight("dummy", 32))

    // CR values
    let challengeId = web3.fromAscii("challenge1")
    let challengeId2 = web3.fromAscii("challenge2")
    let vaeId = util.bufferToHex(util.setLengthRight("vae1", 32))
    let vaeId2 = util.bufferToHex(util.setLengthRight("vae2", 32))
    let challengeType = web3.fromAscii("signing challenge")
    let challenge = web3.fromAscii("sign value 'HELLO'", 128)

    let hash = web3.fromAscii("hash", 32)
    let signature = web3.fromAscii("signature", 128)

    beforeEach('setup contract for each test', async function () {
        authCoin = await AuthCoin.new(accounts[0])
        let dummyVerifier = await DummyVerifier.new(accounts[0])
        await authCoin.registerSignatureVerifier(dummyVerifier.address, contentType)

        await authCoin.registerEir(content, contentType, identifiers, hash, signature)
        await authCoin.registerEir(content2, contentType, identifiers, hash, signature)

        eir1 = EntityIdentityRecord.at(await authCoin.getEir(eirId1))
        eir2 = EntityIdentityRecord.at(await authCoin.getEir(eirId2))
        verifierEirId = await eir1.getId()
        targetEirId = await eir2.getId()

        await authCoin.registerChallengeRecord(challengeId, vaeId, challengeType, challenge, verifierEirId, targetEirId, hash, signature)
        await authCoin.registerChallengeRecord(challengeId2, vaeId, challengeType, challenge, targetEirId, verifierEirId, hash, signature)

        await authCoin.registerChallengeResponse(vaeId, challengeId, web3.fromAscii("content", 128) , hash, signature)
        await authCoin.registerChallengeResponse(vaeId, challengeId2, web3.fromAscii("content2", 128) , hash, signature)

    })

    it("supports adding new challenge signature record", async function () {
        await authCoin.registerChallengeSignature(vaeId, challengeId, 1000, true, hash, signature).then(function(result) {
            // TODO: proper way to catch events from subsequent contract calls
            assert.equal(result.receipt.logs[0].data, "0x00000000000000000000000000000000000000000000000000000000000001e06368616c6c656e676531000000000000000000000000000000000000000000007661653100000000000000000000000000000000000000000000000000000000");
        });
        assert.equal(await authCoin.getVaeCount(), 1)

        let vae = ValidationAuthenticationEntry.at(await authCoin.getVae(vaeId))
        assert.equal(await vae.getVaeId(), vaeId)
        assert.equal(await vae.getChallengesCount(), 2)
        assert.equal(await vae.getChallengeResponseCount(), 2)
        assert.equal(await vae.getChallengeSignatureCount(), 1)
    })

    it("should fail if unknown VAE id is provided", async function () {
        let success = false
        try {
            await authCoin.registerChallengeSignature(vaeId2, challengeId,  1, true, hash, signature)
            success = true
        } catch (error) {

        }
        assert.isNotOk(success)
    })

})
