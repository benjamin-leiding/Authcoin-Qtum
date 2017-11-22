const util = require('ethereumjs-util');
var ValidationAuthenticationEntry = artifacts.require("ValidationAuthenticationEntry");
var ChallengeRecord = artifacts.require("ChallengeRecord");
var ChallengeResponseRecord = artifacts.require("ChallengeResponseRecord");
var EntityIdentityRecord = artifacts.require("EntityIdentityRecord");

contract('ValidationAuthenticationEntry', function (accounts) {

    let vaeId = util.bufferToHex(util.setLengthRight("vae1", 32))
    let eir1
    let eir2
    let challengeRecord1
    let challengeRecord2
    let challengeResponseRecord1;

    // CR values
    let challengeId = web3.fromAscii("challenge1")
    let challengeId2 = web3.fromAscii("challenge2")
    let challengeId3 = web3.fromAscii("challenge3")
    let challengeType = web3.fromAscii("signing challenge")
    let challenge = web3.fromAscii("sign value 'HELLO'", 128)
    let hash = web3.fromAscii("hash", 32)
    let signature = web3.fromAscii("signature", 128)

    // RR values
    let responseContent = web3.fromAscii("content")

    //EIR values
    let identifiers = [web3.fromAscii("test@mail.com", 32), web3.fromAscii("John Doe", 32)]
    let content = web3.fromAscii("content")
    let content2 = web3.fromAscii("content2")
    let eirType = util.bufferToHex(util.setLengthRight("dummy", 32))

    beforeEach('setup contract for each test', async function () {
        eir1 = await EntityIdentityRecord.new(identifiers, content, eirType, hash, signature, accounts[0])
        eir2 = await EntityIdentityRecord.new(identifiers, content2, eirType, hash, signature, accounts[0])

        challengeRecord1 = await ChallengeRecord.new(challengeId, vaeId, challengeType,
            challenge, eir1.address, eir2.address, hash, signature, accounts[0])
        challengeRecord2 = await ChallengeRecord.new(challengeId2, vaeId, challengeType,
            challenge, eir2.address, eir1.address, hash, signature, accounts[0])

        challengeResponseRecord1 = await ChallengeResponseRecord.new(vaeId, challengeId,
            responseContent, hash, signature, accounts[0])

    })

    it("creation must be successful and properly initialized", async function () {
        let vae = await ValidationAuthenticationEntry.new(vaeId, accounts[1])
        assert.equal(await vae.getVaeId(), vaeId);
        assert.equal(await vae.getCreator(), accounts[1]);
        assert.equal(await vae.getChallengesCount(), 0);
    })

    it("should accept new challenge records", async function () {
        let vae = await ValidationAuthenticationEntry.new(vaeId, accounts[1])

        await vae.addChallengeRecord(challengeRecord1.address)
        await vae.addChallengeRecord(challengeRecord2.address)
        assert.equal(await vae.getVaeId(), vaeId);
        assert.equal(await vae.getCreator(), accounts[1]);
        assert.equal(await vae.getChallengesCount(), 2);
    })

    it("should fail if same challenge record is added multiple times", async function () {
        let vae = await ValidationAuthenticationEntry.new(vaeId, accounts[1])
        let challengeRecord = await ChallengeRecord.new(challengeId, vaeId, challengeType,
            challenge, eir1.address, eir2.address, hash, signature, accounts[0])
        await vae.addChallengeRecord(challengeRecord.address)

        let success = false
        try {
            await vae.addChallengeRecord(challengeRecord.address)
            success = true
        } catch (error) {}
        assert.isNotOk(success)
        assert.equal(await vae.getChallengesCount(), 1);
    })

    it("should fail if challenge request VAE is different", async function () {
        let vae = await ValidationAuthenticationEntry.new(vaeId, accounts[1])
        let challengeRecord = await ChallengeRecord.new(challengeId, web3.fromAscii("challenge2"), challengeType,
            challenge, eir1.address, eir2.address, hash, signature, accounts[0])
        let success = false
        try {
            await vae.addChallengeRecord(challengeRecord.address)
            success = true
        } catch (error) {}
        assert.isNotOk(success)
    })

    it("should fail if participants are different", async function () {
        let vae = await ValidationAuthenticationEntry.new(vaeId, accounts[1])
        let cr = await ChallengeRecord.new(challengeId, vaeId, challengeType,
            challenge, eir1.address, eir2.address, hash, signature, accounts[0])
        let cr2 = await ChallengeRecord.new(challengeId2, vaeId, challengeType,
            challenge, accounts[1], eir1.address, hash, signature, accounts[0])

        await vae.addChallengeRecord(cr.address)
        let success = false
        try {
            await vae.addChallengeRecord(cr2.address)
            success = true
        } catch (error) {}
        assert.isNotOk(success)
    })

    it("should fail if participants are different 2", async function () {
        let vae = await ValidationAuthenticationEntry.new(vaeId, accounts[1])
        let cr = await ChallengeRecord.new(challengeId, vaeId, challengeType,
            challenge, eir1.address, eir2.address, hash, signature, accounts[0])
        let cr2 = await ChallengeRecord.new(challengeId2, vaeId, challengeType,
            challenge, eir2.address, accounts[0], hash, signature, accounts[0])

        await vae.addChallengeRecord(cr.address)
        let success = false
        try {
            await vae.addChallengeRecord(cr2.address)
            success = true
        } catch (error) {}
        assert.isNotOk(success)
    })

    it("should fail if more than 2 challenge records are added", async function () {
        let vae = await ValidationAuthenticationEntry.new(vaeId, accounts[1])

        let cr3 = await ChallengeRecord.new(challengeId3, vaeId, challengeType,
            challenge, eir1.address, eir2.address, hash, signature, accounts[0])

        await vae.addChallengeRecord(challengeRecord1.address)
        await vae.addChallengeRecord(challengeRecord2.address)
        let success = false
        try {
            await vae.addChallengeRecord(cr3.address)
            success = true
        } catch (error) {}
        assert.isNotOk(success)
    })

    it("must accept new challenge response records", async function () {
        let vae = await ValidationAuthenticationEntry.new(vaeId, accounts[1])

        await vae.addChallengeRecord(challengeRecord1.address)
        await vae.addChallengeRecord(challengeRecord2.address)
        await vae.addChallengeResponseRecord(challengeResponseRecord1.address)

        assert.equal(await vae.getVaeId(), vaeId);
        assert.equal(await vae.getCreator(), accounts[1]);
        assert.equal(await vae.getChallengesCount(), 2);
        assert.equal(await vae.getChallengeResponseCount(), 1);
    })

    it("should fail if challenge records aren't added before response records", async function () {
        let vae = await ValidationAuthenticationEntry.new(vaeId, accounts[1])

        let success = false
        try {
            await vae.addChallengeResponseRecord(challengeResponseRecord1.address)
            success = true
        } catch (error) {}
        assert.isNotOk(success)
    })

    it("should fail if challenge response record VAE id is invalid", async function () {
        let vae = await ValidationAuthenticationEntry.new(vaeId, accounts[1])

        await vae.addChallengeRecord(challengeRecord1.address)
        await vae.addChallengeRecord(challengeRecord2.address)

        let rr = await ChallengeResponseRecord.new(web3.fromAscii("unknown"), challengeId,
            responseContent, hash, signature, accounts[0])
        let success = false
        try {
            await vae.addChallengeResponseRecord(rr.address)
            success = true
        } catch (error) {}
        assert.isNotOk(success)
    })

    it("should fail if challenge response record challenge id is unknown", async function () {
        let vae = await ValidationAuthenticationEntry.new(vaeId, accounts[1])

        await vae.addChallengeRecord(challengeRecord1.address)
        await vae.addChallengeRecord(challengeRecord2.address)

        let rr = await ChallengeResponseRecord.new(vaeId, web3.fromAscii("unknown"),
            responseContent, hash, signature, accounts[0])
        let success = false
        try {
            await vae.addChallengeResponseRecord(rr.address)
            success = true
        } catch (error) {}
        assert.isNotOk(success)
    })

    it("should fail if challenge response record is added multiple times", async function () {
        let vae = await ValidationAuthenticationEntry.new(vaeId, accounts[1])

        await vae.addChallengeRecord(challengeRecord1.address)
        await vae.addChallengeRecord(challengeRecord2.address)

        await vae.addChallengeResponseRecord(challengeResponseRecord1.address)
        let success = false
        try {
            await vae.addChallengeResponseRecord(challengeResponseRecord1.address)
            success = true
        } catch (error) {}
        assert.isNotOk(success)
    })

})
