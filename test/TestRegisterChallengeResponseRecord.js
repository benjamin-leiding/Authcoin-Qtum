const util = require('ethereumjs-util');
var AuthCoin = artifacts.require("AuthCoin");
var DummyVerifier = artifacts.require("signatures/DummyVerifier");
var EntityIdentityRecord = artifacts.require("EntityIdentityRecord");
var ChallengeRecord = artifacts.require("ChallengeRecord");
var ValidationAuthenticationEntry = artifacts.require("ValidationAuthenticationEntry");

contract('AuthCoin & ChallengeResponseRecord', function (accounts) {

    let authCoin
    let eir1
    let eir2
    let vae //TODO
    let challengeRecord1 //TODO
    let challengeRecord2 //TODO
    let verifierEirId
    let targetEirId

    // EIR values
    let identifiers = [web3.fromAscii("test@mail.com"), web3.fromAscii("John Doe")]
    let content = web3.fromAscii("content")
    let content2 = web3.fromAscii("content2")
    let id = web3.sha3(content, {encoding: 'hex'})
    let id2 = web3.sha3(content2, {encoding: 'hex'})
    let contentType = util.bufferToHex(util.setLengthRight("dummy", 32))

    // CR values
    let challengeId = web3.fromAscii("challenge1")
    let challengeId2 = web3.fromAscii("challenge2")
    let vaeId = util.bufferToHex(util.setLengthRight("vae1", 32))
    let challengeType = web3.fromAscii("signing challenge")
    let challenge = web3.fromAscii("sign value 'HELLO'", 128)

    let hashContent = web3.toHex("0xa1e945cea940a4b22e4d188cb5a5ec5d4dbdb02e07e29976a1230a80c1eccd43")
    let hashContent2 = web3.toHex("0xbb7f3dd4cf198d5b2c1bcc21987c134098732a200a411d5041d0f4b75c292561")
    let hashCallengeRecord = web3.toHex("0x342f63fcce85352bb0cdacb05dcc17bcab0c0586289dd799678b210623d9f7ce")
    let hashCallengeRecord2 = web3.toHex("0xbc21c2f125c3a21c66ddb32ab5f729bdd697d9b3f37c7e6108732c645b5b95e9")

    // CRR values
    let challengeResponseRecordContent = web3.fromAscii("challengeresponse", 128)
    let callengeResponseRecordHash = web3.toHex("0xba8077882ce7b9fe1c17c07cdd822e6e77d0ce5bdc46a2bbe1dc8646d37c2c3d")

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

        await authCoin.registerChallengeRecord(challengeId, vaeId, challengeType, challenge, verifierEirId, targetEirId, hashCallengeRecord, signature)
        await authCoin.registerChallengeRecord(challengeId2, vaeId, challengeType, challenge, targetEirId, verifierEirId, hashCallengeRecord2, signature)
    })

    it("supports adding new challenge response record", async function () {
        var rrEvents = authCoin.LogNewChallengeResponseRecord({_from: web3.eth.coinbase}, {fromBlock: 0, toBlock: 'latest'});
        await authCoin.registerChallengeResponse(vaeId, challengeId, challengeResponseRecordContent, callengeResponseRecordHash, signature)
        assert.equal(await authCoin.getVaeCount(), 1)

        let vae = ValidationAuthenticationEntry.at(await authCoin.getVae(vaeId))
        assert.equal(await vae.getVaeId(), vaeId)
        assert.equal(await vae.getChallengesCount(), 2)
        assert.equal(await vae.getChallengeResponseCount(), 1)

        var event = rrEvents.get()
        assert.equal(event.length, 1);
        assert.equal(event[0].args.challengeId, util.bufferToHex(util.setLengthRight(challengeId, 32)))
    })

    it("should fail when challenge response record is added with unknown VAE id", async function () {
        let success = false
        try {
            await authCoin.registerChallengeResonseRecord(challengeId, util.bufferToHex(util.setLengthRight("unknown", 32)), challengeType, challenge, verifierEirId, web3.fromAscii("dummy", 32), hashCallengeRecord, signature)
            success = true
        } catch (error) {}
        assert.isNotOk(success)
    })

})
