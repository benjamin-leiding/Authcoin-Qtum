const util = require('ethereumjs-util');
var AuthCoin = artifacts.require("AuthCoin");
var ECSignatureVerifier = artifacts.require("signatures/ECSignatureVerifier");
var RsaSignatureVerifier = artifacts.require("signatures/RsaSignatureVerifier");
var EntityIdentityRecord = artifacts.require("EntityIdentityRecord");

contract('Revoke EIR', function (accounts) {

    let authCoin

    // EIR values
    let identifiers = [web3.fromAscii("test@mail.com"), web3.fromAscii("John Doe")]
    let contentRsaPubKey = web3.toHex("0x96b8fb1151ed0d0dfbcdbf4d2487d68d9a6b3f5249e4fe054a7f52a1e0e9c21ce09e9e41efb5bcfe6767d93f652129ca3163314c83eeff1b317a420ae469462f")
    let contentEcPubKey  = web3.toHex("0x192e545a9025d55e6088c55c7755ab3633e3e589")
    let idRsa = web3.sha3(contentRsaPubKey, {encoding: 'hex'})
    let idEc = web3.sha3(contentEcPubKey, {encoding: 'hex'})
    let contentTypeRsa = util.bufferToHex(util.setLengthRight("rsa", 32))
    let contentTypeEc = util.bufferToHex(util.setLengthRight("ec", 32))
    let hashRsa = web3.toHex("0x67186889e71264b969ac98942e798f493099ac30fda7bd316d2903ad586a25df")
    let hashEc = web3.toHex("0xf95c1f2a1a3a6e9bd913588d2b30f5effb94a3d8e40e76c8d542020a629516b9")
    let ecEirSignature = web3.toHex("0xc603e31624f81517d07bafc9e13c012113329400096b4ea8e40e5cb1c99f47c75a6b81180120480118f22b88e5373252dc2590c2d0bd88980a151455ac569b7100", 128)
    let rsaEirSignature = web3.toHex("0x533bb96df50b7ae3013f552a763216aa99d4fb432a98c0f951752a431031cf7c8c5959ebd9d3f54beb9f35e60029b9c4157cf067cece3f1b49977c77576e3327", 128)

    before("setup contract for all tests", async function () {
        authCoin = await AuthCoin.new(accounts[0])
        let ecSignatureVerifier = await ECSignatureVerifier.new(accounts[0])
        let rsaSignatureVerifier = await RsaSignatureVerifier.new(accounts[0])
        await authCoin.registerSignatureVerifier(ecSignatureVerifier.address, contentTypeEc)
        await authCoin.registerSignatureVerifier(rsaSignatureVerifier.address, contentTypeRsa)
        await authCoin.registerEir(contentEcPubKey, contentTypeEc, identifiers, hashEc, ecEirSignature)
        await authCoin.registerEir(contentRsaPubKey, contentTypeRsa, identifiers, hashRsa, rsaEirSignature)
        authCoin.allEvents();
    })

    it("should not revoke EIR with RSA content type and invalid revocation signature", async function () {
        let directKeyRevocationSignature = web3.toHex("0x216c3a465148643dc7eeb38bd79c5453fc98f02fc80a93e39b4f957c0f00bcc3c00af2eeaf076f9be066778bca05a71d5147aca2f6dcb8b00000000000000000", 128)
        await authCoin.revokeEir(directKeyRevocationSignature, contentRsaPubKey);
        let eir = EntityIdentityRecord.at(await authCoin.getEir(idRsa))
        assert.isFalse(await eir.isRevoked())
    })

    it("should not revoke EIR with EC content type and invalid revocation signature", async function () {
        let directKeyRevocationSignature = web3.toHex("0x27dd01b872b09b6007e5f401494caeb75fbc21e61836b1f9d875d07fc468dcb825bf76eaa6cf7090c6a3e365c3e7b1f1bf7a67707f6c0f90000000000000000000", 128)
        await authCoin.revokeEir(directKeyRevocationSignature, contentEcPubKey);
        let eir = EntityIdentityRecord.at(await authCoin.getEir(idEc))
        assert.isFalse(await eir.isRevoked())
    })

    it("should revoke EIR with RSA content type and valid revocation signature", async function () {
        let directKeyRevocationSignature = web3.toHex("0x8b03444462c2b1b85f8c38ebdfd23b577ce38cde624fa059175b93b8faeb86876667ea33a49c5964698e6c9046033a1222234a4daebf86a75c065366211d0135", 128)
        await authCoin.revokeEir(directKeyRevocationSignature, contentRsaPubKey);
        let eir = EntityIdentityRecord.at(await authCoin.getEir(idRsa))
        assert.isTrue(await eir.isRevoked())
    })

    it("should revoke EIR with EC content type and valid revocation signature", async function () {
        let directKeyRevocationSignature = web3.toHex("0xef96651a0fd6ae56e4e362181add26bd06195994f9c84b67e376615e6ccdaed510d470d181be22199e92d6956f534a1c85569624ece8b658d5406246d5473f2a00", 128)
        await authCoin.revokeEir(directKeyRevocationSignature, contentEcPubKey);
        let eir = EntityIdentityRecord.at(await authCoin.getEir(idEc))
        assert.isTrue(await eir.isRevoked())
    })

})
