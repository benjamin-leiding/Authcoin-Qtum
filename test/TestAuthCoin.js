const util = require('ethereumjs-util');
var AuthCoin = artifacts.require("AuthCoin");
var DummyVerifier = artifacts.require("signatures/DummyVerifier");

contract('AuthCoin', function (accounts) {

    let authCoin
    let eirType = util.bufferToHex(util.setLengthRight("dummy", 32))

    beforeEach('setup contract for each test', async function () {
        authCoin = await AuthCoin.new(accounts[0])
    })

    it("supports adding new signature verifiers", async function () {
        let dummyVerifier = await DummyVerifier.new(accounts[0])
        await authCoin.registerSignatureVerifier(dummyVerifier.address, eirType)

        let verifier = await authCoin.getSignatureVerifier(eirType)
        assert.equal(dummyVerifier.address, verifier)
    })

    it("should override old value if new verifier is added using already registered eir type", async function () {
        let dummyVerifier = await DummyVerifier.new(accounts[0])
        let dummyVerifier2 = await DummyVerifier.new(accounts[1])
        let verifiers = await authCoin.getSignatureVerifierTypes()
        assert.equal(verifiers.length, 1)
        await authCoin.registerSignatureVerifier(dummyVerifier.address, eirType)
        await authCoin.registerSignatureVerifier(dummyVerifier2.address, eirType)

        let verifier = await authCoin.getSignatureVerifier(eirType)
        assert.equal(dummyVerifier2.address, verifier)
        verifiers = await authCoin.getSignatureVerifierTypes()
        assert.equal(verifiers.length, 2)
    })

    it("should return empty value if verifier doesn't exist", async function () {
        let verifier = await authCoin.getSignatureVerifier(eirType)
        assert.equal(verifier, '0x0000000000000000000000000000000000000000')
    })

    it("should return all verifier types known to AutCoin contract", async function () {
        let dummyVerifier = await DummyVerifier.new(accounts[0])
        let verifiers = await authCoin.getSignatureVerifierTypes()
        assert.equal(verifiers.length, 1)
        await authCoin.registerSignatureVerifier(dummyVerifier.address, eirType)
        await authCoin.registerSignatureVerifier(dummyVerifier.address, eirType)
        await authCoin.registerSignatureVerifier(dummyVerifier.address, util.bufferToHex(util.setLengthRight("dummy2", 32)))

        verifiers = await authCoin.getSignatureVerifierTypes()
        assert.equal(verifiers.length, 3)
    })

    it("should throw error when verifier isn't added by the owner", async function () {
        let dummyVerifier = await DummyVerifier.new(accounts[0])
        let success = false
        try {
            await authCoin.registerSignatureVerifier(dummyVerifier.address, eirType, {from:accounts[1]})
            success = true
        } catch (error) {}
        assert.isNotOk(success)
    })

})
