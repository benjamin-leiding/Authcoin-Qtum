pragma solidity ^0.4.0;


import "../contracts/signatures/RsaVerify.sol";
import "../contracts/utils/BytesUtils.sol";
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

contract TestRsaSignatureVerification {

    function testVerifyRSASHA256Signature_Keysize512() public {
        bytes32 signedMsg = sha256("abc");

        bytes memory paddedData = hex"0001ffffffffffffffffffff003031300d060960864801650304020105000420ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad";
        bytes memory N = hex"84d2bfadade220628b6d88bb0739dc480fdf164937784a44c42828fb4bbad31687cfaccc73ac9d89722c280eba5165281dcbfba1e12a6e37d3a329285397e5bf";
        uint e = 65537;
        bytes memory S = hex"44ba962f5f3a98ad93f03102f82c66c4759e6cb6174cc334a672b1a043ac1d8af4c0fc1ffb1f288c0f7746372b26642aedd5d37da7f0ea256e0ad6472404e342";

        bytes memory paddedDataMsg = hex"0000000000000000000000000000000000000000000000000000000000000000";
        BytesUtils.memcopy(paddedData, paddedData.length - signedMsg.length, paddedDataMsg, 0, signedMsg.length);
        Assert.equal(keccak256(signedMsg) == keccak256(paddedDataMsg), true, "PKCS1 padded message should contain SHA256 hashed message value");
        Assert.equal(RsaVerify.rsaverify(paddedData, N, e, S), true, "Padded data should be equal to the data recovered from signature");
    }

    function testVerifyRSASHA256Signature_Keysize1024() public {
        bytes32 signedMsg = sha256("abc");

        bytes memory paddedData = hex"0001ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff003031300d060960864801650304020105000420ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad";
        bytes memory N = hex"af24dd35b48fbe48aec610738ffa263a72079ea72160e863cbc38efade8e20b71f411f461405e35beeba29b0794deaf4b2fae56170556573f8136f6919fa360e925e7a8d4730dad7960f56a5e45f58c2c097176a511b4cb1220dcc87f5b54d1f18b31e0f37bc83a9311630af7ce83063428eef51cb3c944a3a5d504fa09bd625";
        uint e = 65537;
        bytes memory S = hex"4bff1d327ad00cc34720aced57908e8ff54f9d32668121c7a4c8ed5bc78f3cdaa1b4c7ae04f9df8b7868328db6003936f89479671b3b4a3f026bf536c15a4701c7bd1ed4f2faa292e98ee1dc91e063ce30dc18e027454e488ed83e9b6d965ecaed414de1ad06fb5a57f2306a2799a5734e6c945b44ad2d0ccb659815901afb4d";

        bytes memory paddedDataMsg = hex"0000000000000000000000000000000000000000000000000000000000000000";
        BytesUtils.memcopy(paddedData, paddedData.length - signedMsg.length, paddedDataMsg, 0, signedMsg.length);
        Assert.equal(keccak256(signedMsg) == keccak256(paddedDataMsg), true, "PKCS1 padded message should contain SHA256 hashed message value");
        Assert.equal(RsaVerify.rsaverify(paddedData, N, e, S), true, "Padded data should be equal to the data recovered from signature");
    }

    function testVerifyRSASHA256Signature_Keysize2048() public {
        bytes32 signedMsg = sha256("abc");

        bytes memory paddedData = hex"0001ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff003031300d060960864801650304020105000420ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad";
        bytes memory N = hex"99ff398d69d46c388fc6896269e23dd97c8408562a0eaf20024d5a1479947f8c51d6553966797bf3772e3c7ddde18bc6213d3b61567a1ad168bfec663b5194a62087bef71efb23845cca26333e17b06eae1efbf32a74805008f3617faf86ffc1e3b7efb6f89f0bfe80d01499c41add3a6b045795bc73bbbc6d70e7ace50775784c620e6b506f48c52d7784c3dc1e35b33c4c7a2203f849316a29250b93ea3a6444e482b24239e999f8ca77d87e49fb2d75dda9189fb15c76801777bd4b26431f6183524919205fccbd2ce78794c0d37cb38e9ef56d018cc46a4139b8d73759431bc73d198619b39a0ba338dba5bb02ca580b5cb9791503986e4be65ff357d81b";
        uint e = 65537;
        bytes memory S = hex"19321184d822b50fec5f347d82985f533240b8b95a700f8b00161bba8f9c11dfd84b595566e72cd623ba232f35aaee9fe7540068b9bf3d38e5e1203bf952d9ae03c896325f027810119a6590727f3aeb6f4e54168a4e57f64b2a64d46c794312d08ee416a61a6719f33f4522e9afb06894e3e8f898a0c87172760ddefcf09af6b3b4bbcddc009b66245cfe1600e38bac8e359b2be3cfb45ec209acf356fd41549f56bb7e5070c2b77d10cff7182d94f34cb8202dc1b6dfd2f5645f0b0a8cf2015634dcbbd5df0289221b95eed0e98555a51d98c621bda75b381be801390e2fecd0aa69d78f374f5060457d54aad020cf3dd80c6bf402bd54e20739c2d19137c0";

        bytes memory paddedDataMsg = hex"0000000000000000000000000000000000000000000000000000000000000000";
        BytesUtils.memcopy(paddedData, paddedData.length - signedMsg.length, paddedDataMsg, 0, signedMsg.length);
        Assert.equal(keccak256(signedMsg) == keccak256(paddedDataMsg), true, "PKCS1 padded message should contain SHA256 hashed message value");
        Assert.equal(RsaVerify.rsaverify(paddedData, N, e, S), true, "Padded data should be equal to the data recovered from signature");
    }

    function testVerifyRSASHA256Signature_Keysize4096() public {
        bytes32 signedMsg = sha256("abc");

        bytes memory paddedData = hex"0001ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff003031300d060960864801650304020105000420ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad";
        bytes memory N = hex"a84f33465f645db50afa9a7bff3b3adf267ca5d37de21fd368c721d885f65c6ab3fd24f9afa1421a6315ab725cdada7bb219b6c11c6f0c678ab3b99ef2a5d69ca15376f74d3aadf87586ffb7dc1f4d10743c4e010253bf1138e3ceda319156eb3df5d7133d41b2d1b86e130bb4eb6cbbbbda4cb204d785601939cd67affad53e7927794e27d84478bb26f93beaf3a3b92cea3b6bd2e64026ff83338c08f780168af11ee24fb434b8ee61822f4580971b80cb9b8b1aa3ae93269d710e0d87c99d19cca70deb2ebcc09ac4b33ba761cb6c8c8f78e1cdaee57f6a97af08c274cc571a5944dfc782ee8e7bfe4b378e43c9e1c6f2d9da20cf12a73d0798b1c81386132463bf5b6891ce5911ced6542a825c450a213b9df4d2bf5ac51e966d43936cd384f1fca7e38453bb6430b0fd03c94ffa7d462e3ae84b2680da9b3c954f09000cc89f9b22f10126957040aa1c80fc7fdbfcc6dd85ba8351e1418088a43bdb04ef53e8f0d9a6a6540ef162ab78447add649850d49a6100617eccfda78ba8f6f9ecae4543e9e12001d8ac6b08682ab9d3965cf8dcb069cfbc97dbbde8bb7a2d822e5558ac12175812f143519e3bc025d7f556227ab71e935f8563b15007d633479006a76567142af837b682ad985524a27d451126418420d94a57882ba3cf7945af518de03c1643b86ce872cc149ce7a2e6b913faa471da236e3522619c64168a35";
        uint e = 65537;
        bytes memory S = hex"99067db8facb0bd2dbcaad968da5143431dcf482993b9bb4acc671231b1e7f4d6b61ee5ac1c956817134ddc239b58cde966f62a8ac2e4712234b00237b264d6148ac6093301188efde21b3ab2823148fbbe47636829b9eed8278b7026cea8dc3f663352755c5e64cb55f1c3b5ebef69219068cc12ee3846075d1372082ec17cf0a196e4e5f6c1e72570cfba6e49fd7e6af3a2df3fff4fd2aa317c90db55220a49ac3b6237c8fc3f08cec8428f644722946600461d45cb96194468fa7532b940281123154898736572fa224964a76ae33ef7c862c6b7a85884c1ca775cefff59a8a5653f2d93b4f9c32979ed88eb18f02b23800b02b47b2c028887f80e1f5f94d3a29724b39a3943a4aa307e575a93228075a17057731c03926a6d77cd29e73cf3118c6d9ce2e123efeb6ee92c98b0589a48c6c1c7ad8defbc40831fd6f73390def9b43f9a821714f2837c82acdde79ccd3c5dc896b799f66d69ad506651d2948486f131de528d6a65463df73eeefa9fcecf7551db9f613fd4f9820526625250d986c77a8872e82dbd586deffe5f79f81014dcc78eaee6023da2dfb5d42109f618687042f3003cb844f4e93278a550acfd0f83552b10b6e0529e8d035661621ea3fd1340dd7d7d4659625564f4fe2bc64fe0734dfb4e85241b9e51748454891377600804f7fc5aca74e6f754624aacd6a875f8c0f7adad163e6bb7b9199e86c57";

        bytes memory paddedDataMsg = hex"0000000000000000000000000000000000000000000000000000000000000000";
        BytesUtils.memcopy(paddedData, paddedData.length - signedMsg.length, paddedDataMsg, 0, signedMsg.length);
        Assert.equal(keccak256(signedMsg) == keccak256(paddedDataMsg), true, "PKCS1 padded message should contain SHA256 hashed message value");
        Assert.equal(RsaVerify.rsaverify(paddedData, N, e, S), true, "Padded data should be equal to the data recovered from signature");
    }
}
