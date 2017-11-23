const util = require('ethereumjs-util');
var AuthCoin = artifacts.require("AuthCoin");
var DummyVerifier = artifacts.require("signatures/DummyVerifier");
var EntityIdentityRecord = artifacts.require("EntityIdentityRecord");

contract('AuthCoin & EIR', function (accounts) {

    let authCoin

    let identifiers = [web3.fromAscii("test@mail.com"), web3.fromAscii("John Doe")]
    let content = web3.fromAscii("content")
    let id = web3.sha3(content, { encoding: 'hex' })

    let contentType = util.bufferToHex(util.setLengthRight("dummy", 32))
    let hash = web3.fromAscii("hash", 32)
    let signature = web3.fromAscii("signature", 128)

    beforeEach('setup contract for each test', async function () {
        authCoin = await AuthCoin.new(accounts[0])
        let dummyVerifier = await DummyVerifier.new(accounts[0])
        await authCoin.registerSignatureVerifier(dummyVerifier.address, contentType)
    })

    it("deployed contract should not contain EIR values", async function () {
        assert.equal(await authCoin.getEirCount(), 0)
    })

    it("should return empty value if EIR doesn't exist", async function () {
        let eir = await authCoin.getEir(0x0)
        assert.equal(eir[0], 0)
    })

    it("supports adding new EIR values", async function () {
        var events = authCoin.LogNewEir({_from:web3.eth.coinbase},{fromBlock: 0, toBlock: 'latest'});
        await authCoin.registerEir(content, contentType, identifiers, hash, signature)

        assert.equal(await authCoin.getEirCount(), 1)

        let eir = EntityIdentityRecord.at(await authCoin.getEir(id))
        assert.equal(await eir.getId(), id)
        assert.equal(await eir.getContentType(), contentType)
        assert.equal(await eir.getContent(), content)
        assert.isNotOk( await eir.isRevoked())
        assert.equal(await eir.getIdentifiersCount(), 2)
        assert.equal(await eir.getIdentifier(0), util.bufferToHex(util.setLengthRight("test@mail.com", 32)))

        var event = events.get()
        assert.equal(event.length, 1);
        assert.equal(event[0].args.eir, await authCoin.getEir(id));
        assert.equal(event[0].args.contentType, contentType);
        assert.equal(event[0].args.id, id);
    })

    it("should fail when EIR is added multiple times", async function () {
        await authCoin.registerEir(content, contentType, identifiers, hash, signature)
        try {
            await authCoin.registerEir(content, contentType, identifiers, hash, signature)
            assert.fail('should have thrown before');
        } catch(error) {}
    })

    it("should fail when EIR unknown signature verifier is used", async function () {
        try {
            await authCoin.registerEir(content, util.bufferToHex(util.setLengthRight("dummy2", 32)), identifiers, hash, signature)
            assert.fail('should have thrown before');
        } catch(error) {}
    })

})
