const util = require('ethereumjs-util');
var AuthCoin = artifacts.require("AuthCoin");
var ECSignatureVerifier = artifacts.require("signatures/ECSignatureVerifier");
var EntityIdentityRecord = artifacts.require("EntityIdentityRecord");

contract('AuthCoin & ChallengeResponseRecord', function (accounts) {

 let authCoin
    let verifierEir
    let targetEir

    // EIR values
    let identifiers = [web3.fromAscii("test@mail.com"), web3.fromAscii("John Doe")]
    let contentType = util.bufferToHex(util.setLengthRight("ec", 32))
    let verifierPk  = web3.toHex("0x192e545a9025d55e6088c55c7755ab3633e3e589")
    let targetPk  = web3.toHex("0x81970d1d41c548cc4b83c7cb5d7d7e6aecdcb1f5")
    let eir1Id = web3.sha3(verifierPk, {encoding: 'hex'})
    let eir2Id = web3.sha3(targetPk, {encoding: 'hex'})
    let verifierEirHash = web3.toHex("0x3365d64d81008b4f4b4399a7b05864c0dbb6a47ac82c34146f6847159a98d726")
    let targetEirHash = web3.toHex("0xeb5ed83a92d2c0e8651b2e56c3bce04475c2db646d96439cc13d9ed8f69cba8b")
    let verifierEirSignature = web3.toHex("0x24f59e7d653d5f1e9f12fe4ee04f2720b708bb99f3e441b1661ea45951b2060368eaf1f19c3d18e067e332f8f8408d651f7257e5bf7f1a6f6e4a5ef5e225587101", 128)
    let targetEirSignature = web3.toHex("0xcc63444aeeaf217fe8323e55d176577994cfc6324f13703cfca525c9960f163f3217520597a54977c73cd3e76c9b3e3165ac5f7c0870d37ae1ddcc7627b0029801", 128)

    // CR values
    let vaeIdForTracking = util.bufferToHex(util.setLengthRight("vae1", 32))
    let challengeIdForEir2 = web3.fromAscii("challenge1")
    let challengeIdForEir1 = web3.fromAscii("challenge2")
    let challengeType = web3.fromAscii("signing challenge")

    let targetCRContent = web3.fromAscii("Message for signing by targetEirId", 128)
    let targetCRHash = web3.toHex("0x3c1911fdab123e261adb08454e6f1a3d4acfd44b06bab8620050821c94b5dc4e")
    let targetCRSignature = web3.toHex("0xed021610e896ace60e88d8936b60f997bd04dc99deac3683757072a0bb3df581513b61013f5dc9cc0ae00a032d031746174c18b4b5eeae0a1dd5e9ad81c576e301", 128)

    let verifierCRContent = web3.fromAscii("Message for signing by verifierEirId", 128)
    let verifierCRHash = web3.toHex("0x8675be9a081011fa72c0cd91432d1ce76a80ad7b6e29b9ec5c122fba0ee90330")
    let verifierCRSignature = web3.toHex("0x9b5f186d54964e8394f9ab62938e961c037f93e2c6cecc356ef41c1be4964ba51b60f7ef579f7a09f407f50b32926a7900679118522309b3595ed35b6e4b95e601", 128)

    // CRR values
    let eir1CRRContent = web3.toHex("0xb0a39d9b950a90fb36c93ca76b32a00f4d18ecd3da3a9eeec6bd069e34120c864b29ab261c36cbab3e31a54bfdc6066bb985d06143ac3a5e651b6af94aba9ee400")
    let eir1CRRHash = web3.toHex("0xf104d7fa6a072debfa877dc2e15dd02b420e64554797fd819b05f7641ba74096")
    let eir1CRRSignature = web3.toHex("0xe741a2573c3e46833cb617d0604f582f6e03806f99735cc635875e8270e69d2d09c6768737b2a813e10de28fcd72f611b9377ce31b55e29c652f5aba5118a7fb00", 128)

    let eir2CRRContent = web3.toHex("0xb983f63954c6af647ae18ab1ca776a55cac2185ce70548b38f7ef04e43810f04466fe7f4cad1a4ea8e2a87d6e829615a29ef6bb5e65150094357a2f79e400e9001")
    let eir2CRRHash = web3.toHex("0x4a2438ad4d4a18948ad67e67c86f5a737d954378eb4cbe1d1ca318e490e282fd")
    let eir2CRRSignature = web3.toHex("0x2866ccaf2ef18c87351f7f89b0453ba8211ae6ecaa3ccbd3925e11a5c394e87e13bd88096442e3e6d156dfda4fe932fe074b4248cf1cbda2737bf909abb47bcd01", 128)

    // CSR values
    let eir1SRHash = web3.toHex("0xc22152608c0b6c0c696aaefe6a5e6e67ef3c79a9465673a7acd0726c2d9d0e60")
    let eir1SRSignature = web3.toHex("0xb8c5466b41749ebbcff78447800aaba6130f1edf8172c7fa0a4ed0bd5838c6be6d0c8ba035501d67327a00161ad5a45d5b429adbdc6db2e63ad05805b47775b301")
    
    let eir2SRHash = web3.toHex("0x2b23dfc591ee785993e84f19d82a30bbdbb8b3d1391edeccd97b729a7cb0b921")
    let eir2SRSignature = web3.toHex("0xc6aab966b7ba41e69a71e0cbfb69b5c987b6ab41a17e63ce8b7d89ab92fb628535dd02dbe02e874038efd14b0b66c1ecc123704998b7ebe6810cc4360d743b8700")

    beforeEach('setup verifier Challenge Record for target to respond', async function () {
        authCoin = await AuthCoin.new(accounts[0])
        let ecSignatureVerifier = await ECSignatureVerifier.new(accounts[0])
        await authCoin.registerSignatureVerifier(ecSignatureVerifier.address, contentType)
        await authCoin.registerEir(verifierPk, contentType, identifiers, verifierEirHash, verifierEirSignature)
        await authCoin.registerEir(targetPk, contentType, identifiers, targetEirHash, targetEirSignature)
        verifierEir = EntityIdentityRecord.at(await authCoin.getEir(eir1Id))
        targetEir = EntityIdentityRecord.at(await authCoin.getEir(eir2Id))

        await authCoin.registerChallengeRecord(challengeIdForEir2, vaeIdForTracking, challengeType, targetCRContent, eir1Id, eir2Id, targetCRHash, targetCRSignature) // Eir1 -> Eir2
        await authCoin.registerChallengeRecord(challengeIdForEir1, vaeIdForTracking, challengeType, verifierCRContent, eir2Id, eir1Id, verifierCRHash, verifierCRSignature) // Eir2 -> Eir1

        await authCoin.registerChallengeResponse(vaeIdForTracking, challengeIdForEir2, eir2CRRContent, eir2CRRHash, eir2CRRSignature)  // Eir2
        await authCoin.registerChallengeResponse(vaeIdForTracking, challengeIdForEir1, eir1CRRContent, eir1CRRHash, eir1CRRSignature) // Eir1
    })

    it("should add target ChallengeSignatureRecord with valid hash and signature by EIR1 (Alice)", async function () {
        let success = false
        try {
            await authCoin.registerSignatureRecord(vaeIdForTracking, challengeIdForEir1, 1000, true, eir2SRHash, eir2SRSignature) // Eir1 accepts Eir2
            success = true
        } catch (error) {}
        assert.isOk(success)
    })

    it("should add target ChallengeSignatureRecord with valid hash and signature by EIR2 (Bob)", async function () {
        let success = false
        try {
            await authCoin.registerSignatureRecord(vaeIdForTracking, challengeIdForEir2, 1000, true, eir1SRHash, eir1SRSignature) // Eir1 accepts Eir2
            success = true
        } catch (error) {}
        assert.isOk(success)
    })

})
