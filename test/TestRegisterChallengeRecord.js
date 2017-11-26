const util = require('ethereumjs-util');
var AuthCoin = artifacts.require("AuthCoin");
var DummyVerifier = artifacts.require("signatures/DummyVerifier");
var EntityIdentityRecord = artifacts.require("EntityIdentityRecord");
var ChallengeRecord = artifacts.require("ChallengeRecord");
var ValidationAuthenticationEntry = artifacts.require("ValidationAuthenticationEntry");

contract('AuthCoin & ChallengeRecord', function (accounts) {

    let authCoin
    let eir1
    let eir2

    // EIR values
    let identifiers = [web3.fromAscii("test@mail.com"), web3.fromAscii("John Doe")]
    let content = web3.fromAscii("content")
    let content2 = web3.fromAscii("content2")
    let id = web3.sha3(content, {encoding: 'hex'})
    let id2 = web3.sha3(content2, {encoding: 'hex'})
    let contentType = util.bufferToHex(util.setLengthRight("dummy", 32))

    // CR values
    let challengeId = web3.fromAscii("challenge1")
    let vaeId = util.bufferToHex(util.setLengthRight("vae1", 32))


    let challengeType = web3.fromAscii("signing challenge")
    let challenge = web3.fromAscii("sign value 'HELLO'", 128)
    let verifierEirId
    let targetEirId
    let hashContent = web3.toHex("0x27ecdf018bbc32178ec05108bdc85d634a9b324ff77963208197a6975623e82b")
    let hashContent2 = web3.toHex("0x567c642db189fc0864c49bb42c11402289e9e62105004703d034434228bc0c08")
    let signature = web3.fromAscii("signature", 128)

    beforeEach('setup contract for each test', async function () {
        authCoin = await AuthCoin.new(accounts[0])
        let dummyVerifier = await DummyVerifier.new(accounts[0])
        await authCoin.registerSignatureVerifier(dummyVerifier.address, contentType)

        await authCoin.registerEir(content, contentType, identifiers, hashContent, signature)
        await authCoin.registerEir(content2, contentType, identifiers, hashContent2, signature)

        eir1 = EntityIdentityRecord.at(await authCoin.getEir(id))
        eir2 = EntityIdentityRecord.at(await authCoin.getEir(id2))
        verifierEirId = await eir1.getId()
        targetEirId = await eir2.getId()

    })

    it("should fail when challenge records is added using unknown verifier EIR", async function () {
        let success = false
        try {
            await authCoin.registerChallengeRecord(challengeId, vaeId, challengeType, challenge, web3.fromAscii("dummy", 32), targetEirId, hashContent, signature)
            success = true
        } catch (error) {}
        assert.isNotOk(success)
    })

    it("should fail when challenge records is added using unknown target EIR", async function () {
        let success = false
        try {
            await authCoin.registerChallengeRecord(challengeId, vaeId, challengeType, challenge, verifierEirId, web3.fromAscii("dummy", 32), hashContent, signature)
            success = true
        } catch (error) {}
        assert.isNotOk(success)
    })

    it("supports adding new challenge record", async function () {
        var vaeEvents = authCoin.LogNewVae({_from: web3.eth.coinbase}, {fromBlock: 0, toBlock: 'latest'});
        await authCoin.registerChallengeRecord(challengeId, vaeId, challengeType, challenge, verifierEirId, targetEirId, hashContent, signature)

        assert.equal(await authCoin.getVaeCount(), 1)

        let vae = ValidationAuthenticationEntry.at(await authCoin.getVae(vaeId))
        assert.equal(await vae.getVaeId(), vaeId)
        assert.equal(await vae.getChallengesCount(), 1)

        var event = vaeEvents.get()
        assert.equal(event.length, 1);
        assert.equal(event[0].args.id, vaeId)
    })

})
