const util = require('ethereumjs-util');
var ValidationAuthenticationEntry = artifacts.require("ValidationAuthenticationEntry");
var EntityIdentityRecord = artifacts.require("EntityIdentityRecord");
var DummyVerifier = artifacts.require("signatures/DummyVerifier");

contract('ValidationAuthenticationEntry', function (accounts) {

    let vaeId = util.bufferToHex(util.setLengthRight("vae1", 32))
    let vaeId2 = util.bufferToHex(util.setLengthRight("vae2", 32))
    let eir1
    let eir2

    // CR values
    let challengeId = web3.fromAscii("challenge1")
    let challengeId2 = web3.fromAscii("challenge2")
    let challengeId3 = web3.fromAscii("challenge3")
    let challengeType = web3.fromAscii("signing challenge")
    let challenge = web3.fromAscii("sign value 'HELLO'", 128)
    let hash = web3.fromAscii("hash", 32)
    let signature = web3.fromAscii("signature", 128)

    // RR values
    let responseContent = web3.fromAscii("challengeresponse", 128)
    let responseHash = web3.toHex("0xba8077882ce7b9fe1c17c07cdd822e6e77d0ce5bdc46a2bbe1dc8646d37c2c3d")
	let responseHash1 = web3.toHex("0x10447f9447dd21a763b10a344a06b790b171125aed7179f72940c5b68321e5f9")
	let responseHashUnknown = web3.toHex("0x33ab355bca41fb09d659746cb4a1034aeb69538d05f4dcb2608f8117993f25cf")

	// SR values
    let signatureRecordHash1 = web3.toHex("0xb57c81638d82f7746528c56ba6120c4522a50455588bef00d499f58dc7ed5adf")
    let signatureRecordHash2 = web3.toHex("0x12b4205ffb323e835f5e6df19ad05c425ddad327cd207008f43d6ca2f982e54d")
    let signatureRecordHashUnknown = web3.toHex("0x6ba7448662dbe4911f6ec0167624264cd7d32b2e5e69d616595b2625d56d3d26")

    //EIR values
    let identifiers = [web3.fromAscii("test@mail.com", 32), web3.fromAscii("John Doe", 32)]
    let content = web3.fromAscii("content")
    let content2 = web3.fromAscii("content2")
    let eirType = util.bufferToHex(util.setLengthRight("dummy", 32))

    beforeEach('setup contract for each test', async function () {
        let dummyVerifier = await DummyVerifier.new(accounts[0])
        eir1 = await EntityIdentityRecord.new(identifiers, content, eirType, hash, signature, dummyVerifier.address, accounts[0])
        eir2 = await EntityIdentityRecord.new(identifiers, content2, eirType, hash, signature, dummyVerifier.address, accounts[0])
    })

    it("creation must be successful and properly initialized", async function () {
        let vae = await ValidationAuthenticationEntry.new(vaeId, accounts[1])
        assert.equal(await vae.getVaeId(), vaeId);
        assert.equal(await vae.getOwner(), accounts[1]);
        assert.equal(await vae.getChallengeCount(), 0);
    })

    it("should accept new challenge records", async function () {
        let vae = await ValidationAuthenticationEntry.new(vaeId, accounts[1])

        await vae.addChallengeRecord(challengeId, vaeId, challengeType,
            challenge, eir1.address, eir2.address, hash, signature, accounts[0])
        await vae.addChallengeRecord(challengeId2, vaeId, challengeType,
            challenge, eir2.address, eir1.address, hash, signature, accounts[0])
        assert.equal(await vae.getVaeId(), vaeId);
        assert.equal(await vae.getOwner(), accounts[1]);
        assert.equal(await vae.getChallengeCount(), 2);
    })

    it("should fail if same challenge record is added multiple times", async function () {
        let vae = await ValidationAuthenticationEntry.new(vaeId, accounts[1])
        await vae.addChallengeRecord(challengeId, vaeId, challengeType,
            challenge, eir1.address, eir2.address, hash, signature, accounts[0])

        let success = false
        try {
            await vae.addChallengeRecord(challengeId, vaeId, challengeType,
                challenge, eir1.address, eir2.address, hash, signature, accounts[0])
            success = true
        } catch (error) {}
        assert.isNotOk(success)
        assert.equal(await vae.getChallengeCount(), 1);
    })

    it("should fail if challenge request VAE is different", async function () {
        let vae = await ValidationAuthenticationEntry.new(vaeId, accounts[1])
        await vae.addChallengeRecord(challengeId, vaeId, challengeType,
            challenge, eir1.address, eir2.address, hash, signature, accounts[0])
        let success = false
        try {
            await vae.addChallengeRecord(challengeId, vaeId2, challengeType,
                challenge, eir1.address, eir2.address, hash, signature, accounts[0])
            success = true
        } catch (error) {}
        assert.isNotOk(success)
    })

    it("should fail if participants are different", async function () {
        let vae = await ValidationAuthenticationEntry.new(vaeId, accounts[1])
        await vae.addChallengeRecord(challengeId, vaeId, challengeType,
            challenge, eir1.address, eir2.address, hash, signature, accounts[0])
        let success = false
        try {
            await vae.addChallengeRecord(challengeId2, vaeId, challengeType,
                challenge, accounts[1], eir1.address, hash, signature, accounts[0])
            success = true
        } catch (error) {}
        assert.isNotOk(success)
    })

    it("should fail if participants are different 2", async function () {
        let vae = await ValidationAuthenticationEntry.new(vaeId, accounts[1])
        await vae.addChallengeRecord(challengeId, vaeId, challengeType,
            challenge, eir1.address, eir2.address, hash, signature, accounts[0])
        let success = false
        try {
            await vae.addChallengeRecord(challengeId2, vaeId, challengeType,
                challenge, eir2.address, accounts[0], hash, signature, accounts[0])
            success = true
        } catch (error) {}
        assert.isNotOk(success)
    })

    it("should fail if more than 2 challenge records are added", async function () {
        let vae = await ValidationAuthenticationEntry.new(vaeId, accounts[1])
        await vae.addChallengeRecord(challengeId, vaeId, challengeType,
            challenge, eir1.address, eir2.address, hash, signature, accounts[0])
        await vae.addChallengeRecord(challengeId2, vaeId, challengeType,
            challenge, eir2.address, eir1.address, hash, signature, accounts[0])

        let success = false
        try {
            await vae.addChallengeRecord(challengeId3, vaeId, challengeType,
                challenge, eir1.address, eir2.address, hash, signature, accounts[0])
            success = true
        } catch (error) {}
        assert.isNotOk(success)
    })

    it("must accept new challenge response records", async function () {
        let vae = await ValidationAuthenticationEntry.new(vaeId, accounts[1])

        await vae.addChallengeRecord(challengeId, vaeId, challengeType,
            challenge, eir1.address, eir2.address, hash, signature, accounts[0])
        await vae.addChallengeRecord(challengeId2, vaeId, challengeType,
            challenge, eir2.address, eir1.address, hash, signature, accounts[0])
        await vae.addChallengeResponseRecord(vaeId, challengeId,
            responseContent, responseHash, signature, accounts[0])

        assert.equal(await vae.getVaeId(), vaeId);
        assert.equal(await vae.getOwner(), accounts[1]);
        assert.equal(await vae.getChallengeCount(), 2);
        assert.equal(await vae.getChallengeResponseCount(), 1);
    })

    it("should fail if challenge records aren't added before response records", async function () {
        let vae = await ValidationAuthenticationEntry.new(vaeId, accounts[1])

        let success = false
        try {
            await vae.addChallengeResponseRecord(vaeId, challengeId,
                responseContent, responseHash, signature, accounts[0])
            success = true
        } catch (error) {}
        assert.isNotOk(success)
    })

    it("should fail if challenge response record VAE id is invalid", async function () {
        let vae = await ValidationAuthenticationEntry.new(vaeId, accounts[1])

        await vae.addChallengeRecord(challengeId, vaeId, challengeType,
            challenge, eir1.address, eir2.address, hash, signature, accounts[0])
        await vae.addChallengeRecord(challengeId2, vaeId, challengeType,
            challenge, eir2.address, eir1.address, hash, signature, accounts[0])

        let success = false
        try {
            await vae.addChallengeResponseRecord(web3.fromAscii("unknown"), challengeId,
                responseContent, responseHashUnknown, signature, accounts[0])
            success = true
        } catch (error) {}
        assert.isNotOk(success)
    })

    it("should fail if challenge response record challenge id is unknown", async function () {
        let vae = await ValidationAuthenticationEntry.new(vaeId, accounts[1])

        await vae.addChallengeRecord(challengeId, vaeId, challengeType,
            challenge, eir1.address, eir2.address, hash, signature, accounts[0])
        await vae.addChallengeRecord(challengeId2, vaeId, challengeType,
            challenge, eir2.address, eir1.address, hash, signature, accounts[0])

        let success = false
        try {
            await vae.addChallengeResponseRecord(vaeId, web3.fromAscii("unknown"),
                responseContent, responseHashUnknown, signature, accounts[0])
            success = true
        } catch (error) {}
        assert.isNotOk(success)
    })

    it("should fail if challenge response record is added multiple times", async function () {
        let vae = await ValidationAuthenticationEntry.new(vaeId, accounts[1])

        await vae.addChallengeRecord(challengeId, vaeId, challengeType,
            challenge, eir1.address, eir2.address, hash, signature, accounts[0])
        await vae.addChallengeRecord(challengeId2, vaeId, challengeType,
            challenge, eir2.address, eir1.address, hash, signature, accounts[0])

        await vae.addChallengeResponseRecord(vaeId, challengeId,
            responseContent, responseHash, signature, accounts[0])
        let success = false
        try {
            await vae.addChallengeResponseRecord(vaeId, challengeId,
                responseContent, responseHash, signature, accounts[0])
            success = true
        } catch (error) {}
        assert.isNotOk(success)
    })

    it("must accept new challenge signature records", async function () {
        let vae = await ValidationAuthenticationEntry.new(vaeId, accounts[1])

        await vae.addChallengeRecord(challengeId, vaeId, challengeType,
            challenge, eir1.address, eir2.address, hash, signature, accounts[0])
        await vae.addChallengeRecord(challengeId2, vaeId, challengeType,
            challenge, eir2.address, eir1.address, hash, signature, accounts[0])
        await vae.addChallengeResponseRecord(vaeId, challengeId,
            responseContent, responseHash, signature, accounts[0])
        await vae.addChallengeResponseRecord(vaeId, challengeId2,
            responseContent, responseHash1, signature, accounts[0])

        await vae.addChallengeSignatureRecord(vaeId,challengeId2,
            100000, true, signatureRecordHash2, signature, accounts[0])
        await vae.addChallengeSignatureRecord(vaeId,challengeId,
            100000, true, signatureRecordHash1, signature, accounts[0])
        assert.equal(await vae.getVaeId(), vaeId);
        assert.equal(await vae.getOwner(), accounts[1]);
        assert.equal(await vae.getChallengeCount(), 2);
        assert.equal(await vae.getChallengeResponseCount(), 2);

        assert.equal(await vae.getChallengeSignatureCount(), 2);
    })

    it("adding signature record should fail if VAE doesn't contain challenge records", async function () {
        let vae = await ValidationAuthenticationEntry.new(vaeId, accounts[1])

        let success = false
        try {
            await vae.addChallengeSignatureRecord(vaeId,challengeId2,
                100000, true, hash, signature, accounts[0])
            success = true
        } catch (error) {
        }
        assert.isNotOk(success)
    })

    it("adding signature record should fail if VAE doesn't contain challenge response records", async function () {
        let vae = await ValidationAuthenticationEntry.new(vaeId, accounts[1])

        await vae.addChallengeRecord(challengeId, vaeId, challengeType,
            challenge, eir1.address, eir2.address, hash, signature, accounts[0])
        await vae.addChallengeRecord(challengeId2, vaeId, challengeType,
            challenge, eir2.address, eir1.address, hash, signature, accounts[0])
        let success = false
        try {
            await vae.addChallengeSignatureRecord(vaeId,challengeId2,
                100000, true, hash, signature, accounts[0])
            success = true
        } catch (error) {
        }
        assert.isNotOk(success)
    })

    it("should fail if more than 2 signature records are added", async function () {
        let vae = await ValidationAuthenticationEntry.new(vaeId, accounts[1])

        await vae.addChallengeRecord(challengeId, vaeId, challengeType,
            challenge, eir1.address, eir2.address, hash, signature, accounts[0])
        await vae.addChallengeRecord(challengeId2, vaeId, challengeType,
            challenge, eir2.address, eir1.address, hash, signature, accounts[0])
        await vae.addChallengeResponseRecord(vaeId, challengeId,
            responseContent, responseHash, signature, accounts[0])
        await vae.addChallengeResponseRecord(vaeId, challengeId2,
            responseContent, responseHash1, signature, accounts[0])

        await vae.addChallengeSignatureRecord(vaeId,challengeId2,
            100000, true, signatureRecordHash2, signature, accounts[0])
        await vae.addChallengeSignatureRecord(vaeId,challengeId,
            100000, true, signatureRecordHash1, signature, accounts[0])
        let success = false
        try {
            await vae.addChallengeSignatureRecord(vaeId,challengeId,
                100000, true, signatureRecordHash1, signature, accounts[0])
            success = true
        } catch (error) {
        }
        assert.isNotOk(success)
    })

    it("signature record can not be overwritten", async function () {
        let vae = await ValidationAuthenticationEntry.new(vaeId, accounts[1])

        await vae.addChallengeRecord(challengeId, vaeId, challengeType,
            challenge, eir1.address, eir2.address, hash, signature, accounts[0])
        await vae.addChallengeRecord(challengeId2, vaeId, challengeType,
            challenge, eir2.address, eir1.address, hash, signature, accounts[0])
        await vae.addChallengeResponseRecord(vaeId, challengeId,
            responseContent, responseHash, signature, accounts[0])
        await vae.addChallengeResponseRecord(vaeId, challengeId2,
            responseContent, responseHash1, signature, accounts[0])

        await vae.addChallengeSignatureRecord(vaeId,challengeId2,
            100000, true, signatureRecordHash2, signature, accounts[0])
        let success = false
        try {
            await vae.addChallengeSignatureRecord(vaeId,challengeId2,
                100000, true, signatureRecordHash2, signature, accounts[0])
            success = true
        } catch (error) {
        }
        assert.isNotOk(success)
    })


    it("signature record can not be added without corresponding challenge record", async function () {
        let vae = await ValidationAuthenticationEntry.new(vaeId, accounts[1])

        await vae.addChallengeRecord(challengeId, vaeId, challengeType,
            challenge, eir1.address, eir2.address, hash, signature, accounts[0])
        await vae.addChallengeRecord(challengeId2, vaeId, challengeType,
            challenge, eir2.address, eir1.address, hash, signature, accounts[0])
        await vae.addChallengeResponseRecord(vaeId, challengeId,
            responseContent, responseHash, signature, accounts[0])
        await vae.addChallengeResponseRecord(vaeId, challengeId2,
            responseContent, responseHash1, signature, accounts[0])

        let success = false
        try {
            await vae.addChallengeSignatureRecord(vaeId,web3.fromAscii("unknown"),
                100000, true, signatureRecordHashUnknown, signature, accounts[0])
            success = true
        } catch (error) {
        }
        assert.isNotOk(success)
    })
})
