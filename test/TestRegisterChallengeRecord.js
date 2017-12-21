const util = require('ethereumjs-util');
var AuthCoin = artifacts.require("AuthCoin");
var DummyVerifier = artifacts.require("signatures/DummyVerifier");
var EntityIdentityRecord = artifacts.require("EntityIdentityRecord");
var ValidationAuthenticationEntry = artifacts.require("ValidationAuthenticationEntry");

contract('AuthCoin & ChallengeRecord', function (accounts) {

    let authCoin
    let eir1
    let eir2
    let verifierEirId
    let targetEirId

    // EIR values
    let identifiers = [web3.fromAscii("test@mail.com"), web3.fromAscii("John Doe")]
    let content = web3.fromAscii("content")
    let content2 = web3.fromAscii("content2")
    let id = web3.sha3(content, {encoding: 'hex'})
    let id2 = web3.sha3(content2, {encoding: 'hex'})
    let contentType = util.bufferToHex(util.setLengthRight("dummy", 32))
    let eirHash1 = web3.toHex("0xa1e945cea940a4b22e4d188cb5a5ec5d4dbdb02e07e29976a1230a80c1eccd43")
    let eirHash2 = web3.toHex("0xbb7f3dd4cf198d5b2c1bcc21987c134098732a200a411d5041d0f4b75c292561")

    // CR values
    let challengeId = web3.fromAscii("challenge1")
    let vaeId = util.bufferToHex(util.setLengthRight("vae1", 32))
    let challengeType = web3.fromAscii("signing challenge")
    let challenge = web3.fromAscii("sign value 'HELLO'", 128)
    let challengeHash = web3.toHex("0x342f63fcce85352bb0cdacb05dcc17bcab0c0586289dd799678b210623d9f7ce")

    let signature = web3.fromAscii("signature", 128)

    beforeEach('setup contract for each test', async function () {
        authCoin = await AuthCoin.new(accounts[0])
        let dummyVerifier = await DummyVerifier.new(accounts[0])
        await authCoin.registerSignatureVerifier(dummyVerifier.address, contentType)
        await authCoin.registerEir(content, contentType, identifiers, eirHash1, signature)
        await authCoin.registerEir(content2, contentType, identifiers, eirHash2, signature)
        eir1 = EntityIdentityRecord.at(await authCoin.getEir(id))
        eir2 = EntityIdentityRecord.at(await authCoin.getEir(id2))
        verifierEirId = await eir1.getId()
        targetEirId = await eir2.getId()
    })

    it("should fail when challenge records is added using unknown verifier EIR", async function () {
        let success = false
        try {
            await authCoin.registerChallengeRecord(challengeId, vaeId, challengeType, challenge, web3.fromAscii("dummy", 32), targetEirId, challengeHash, signature)
            success = true
        } catch (error) {}
        assert.isNotOk(success)
    })

    it("should fail when challenge records is added using unknown target EIR", async function () {
        let success = false
        try {
            await authCoin.registerChallengeRecord(challengeId, vaeId, challengeType, challenge, verifierEirId, web3.fromAscii("dummy", 32), challengeHash, signature)
            success = true
        } catch (error) {}
        assert.isNotOk(success)
    })

    it("supports adding new challenge record", async function () {
        var vaeEvents = authCoin.LogNewVae({_from: web3.eth.coinbase}, {fromBlock: 0, toBlock: 'latest'});

        await authCoin.registerChallengeRecord(challengeId, vaeId, challengeType, challenge, verifierEirId, targetEirId, challengeHash, signature)
        assert.equal(await authCoin.getVaeCount(), 1)

        let vae = ValidationAuthenticationEntry.at(await authCoin.getVae(vaeId))
        assert.equal(await vae.getVaeId(), vaeId)
        assert.equal(await vae.getChallengeCount(), 1)

        var event = vaeEvents.get()
        assert.equal(event.length, 1);
        assert.equal(event[0].args.id, vaeId)
    })

    it("querying VAE array by EIR id", async function () {
        var vaeEvents = authCoin.LogNewVae({_from: web3.eth.coinbase}, {fromBlock: 0, toBlock: 'latest'});
        await authCoin.registerChallengeRecord(challengeId, vaeId, challengeType, challenge, verifierEirId, targetEirId, challengeHash, signature)

        assert.equal(await authCoin.getVaeCount(), 1)

        let vaeArray = await authCoin.getVaeArrayByEirId(verifierEirId);
        assert.equal(vaeArray.length, 1)

        let vaeArray2 = await authCoin.getVaeArrayByEirId(targetEirId);
        assert.equal(vaeArray2.length, 1)
        assert.equal(vaeArray[0], vaeArray2[0])

        var event = vaeEvents.get()
        assert.equal(event[0].args.vaeAddress, vaeArray[0])
    })

    it("querying VAE array by EIR that doesn't have any challenges return empty array", async function () {
        let vaeArray = await authCoin.getVaeArrayByEirId(verifierEirId);
        assert.equal(vaeArray.length, 0)
    })

})
