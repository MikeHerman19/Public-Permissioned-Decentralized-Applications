// This file is MIT Licensed.
//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
pragma solidity ^0.8.0;
library Pairing {
    struct G1Point {
        uint X;
        uint Y;
    }
    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }
    /// @return the generator of G1
    function P1() pure internal returns (G1Point memory) {
        return G1Point(1, 2);
    }
    /// @return the generator of G2
    function P2() pure internal returns (G2Point memory) {
        return G2Point(
            [10857046999023057135944570762232829481370756359578518086990519993285655852781,
             11559732032986387107991004021392285783925812861821192530917403151452391805634],
            [8495653923123431417604973247489272438418190587263600148770280649306958101930,
             4082367875863433681332203403145435568316851327593401208105741076214120093531]
        );
    }
    /// @return the negation of p, i.e. p.addition(p.negate()) should be zero.
    function negate(G1Point memory p) pure internal returns (G1Point memory) {
        // The prime q in the base field F_q for G1
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0)
            return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }
    /// @return r the sum of two points of G1
    function addition(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {
        uint[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
    }


    /// @return r the product of a point on G1 and a scalar, i.e.
    /// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.
    function scalar_mul(G1Point memory p, uint s) internal view returns (G1Point memory r) {
        uint[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require (success);
    }
    /// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal view returns (bool) {
        require(p1.length == p2.length);
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[1];
            input[i * 6 + 3] = p2[i].X[0];
            input[i * 6 + 4] = p2[i].Y[1];
            input[i * 6 + 5] = p2[i].Y[0];
        }
        uint[1] memory out;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
        return out[0] != 0;
    }
    /// Convenience method for a pairing check for two pairs.
    function pairingProd2(G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for three pairs.
    function pairingProd3(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](3);
        G2Point[] memory p2 = new G2Point[](3);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for four pairs.
    function pairingProd4(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2,
            G1Point memory d1, G2Point memory d2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](4);
        G2Point[] memory p2 = new G2Point[](4);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p1[3] = d1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        p2[3] = d2;
        return pairing(p1, p2);
    }
}

contract Verifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G1Point alpha;
        Pairing.G2Point beta;
        Pairing.G2Point gamma;
        Pairing.G2Point delta;
        Pairing.G1Point[] gamma_abc;
    }
    struct Proof {
        Pairing.G1Point a;
        Pairing.G2Point b;
        Pairing.G1Point c;
    }
    function verifyingKey() pure internal returns (VerifyingKey memory vk) {
        vk.alpha = Pairing.G1Point(uint256(0x1f0663f37ba6508c53e1f5e78e5d29db7e0477aa1b00dd8b9048ce137d310597), uint256(0x07b3d358812d76ecc3ce0ee00c4e3d1cc7521e4981f856bb84b6e3615b2a1428));
        vk.beta = Pairing.G2Point([uint256(0x2270984f5ac799c2b677b04b78bff02cd6af3e9128a12057a24ea232981373c8), uint256(0x068c0d5a9bd5dfcfb307b1517f1d86fabc2e8649e41b895ca4ed84cdbecb4383)], [uint256(0x0767923077956314b894ca9ef810d3f93e6f4f8c98a04bc38bc75ee95256e0b5), uint256(0x21f6eea63599f09366d0bcc0c7a48f2a88ab06ea722509a4dffcbecc6c1f0bf2)]);
        vk.gamma = Pairing.G2Point([uint256(0x276243e8d1410cc192b110808ec7a09363a5cf88148ae4ed9280383c853a23ce), uint256(0x19d1f2ee87dde05a243f895b947be896ac3e19a58b6a243ef23ac183a771aa44)], [uint256(0x17d9180136569e363f59e17b0521e967815380e8460e8dbcfd02dad73d060456), uint256(0x1e63972b27bda365970bbe9887f7eba7279444a79905ed2a026bf68c4201b259)]);
        vk.delta = Pairing.G2Point([uint256(0x07a547cf817f14808f484518e3e25f5a817469bf0cd48c39bbd288d59b0eb561), uint256(0x2f6273e7c3ef1422805caf1d9d296ca92e16b5f02ff171811cedfe5c76c24220)], [uint256(0x293e0ac81fbe7e2b20035ab5e7ece8bcccd714643e5ca2aa48b27454435dfe35), uint256(0x155e2b5303ce3e91b9387fbc4d4d97f741feeffaf6b49958947873f42bc7716c)]);
        vk.gamma_abc = new Pairing.G1Point[](57);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x23f26f91970fd8830f8df7d59afe1f1c0bc6eda990e619570c8ef81fd6389a65), uint256(0x04b48047e6351203fa1746949b81675f21202d397e39e7c3cea796e59bb53ed5));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x1025b7424c5691b01fa531430c365086a9fa7ee00ebcd5540691226d1f722096), uint256(0x20ce8525cdc37cc193355367b01f26251b8fbdd66580b962e2735e46641d6ad1));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x283f9a272538369b066e07b1c2b4e4b86c22b3345b9c57c99315fcdd0cd92414), uint256(0x1ef8154dc47c83aecb9254c9a003fc44ca0e80d050953b7d85cc86e47eb6028c));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x20da199fc0036c84c3e11b9383167cf2fe12887b3084aff87bc5163f2130d7bc), uint256(0x056d82a1ce1c887cc095978d12e7fc30736e476059ed4f6d1995109eb8bc6715));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x1664cd46a3aa541c142724fa34fec9cae09eb206aec0a9a900974e14fe656b88), uint256(0x20002c0433904f9bb2f897f7eb37dd5fca8395943af00b8d0ae0d95beed2287e));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x0379bff4b590cd9bba50f7aef36c0784cab15f2f58d5e36b6a3982685a4672e5), uint256(0x1f6a562a1b769777a50fd2c61518c465fe75ba2308b2da459674159146a1d6ac));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x070b056c32d6fc1590e7fa0f9da8f6879e8390bc89be4e07b36a65227eaac735), uint256(0x1819534d67e616707ec55ba7094f2da72a87ea3b0ff253b7d2e76b68e064c3e7));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x16cf72460f16cf678d83f6fb9489cd11daf5adc466e5380901d600a1358ecc44), uint256(0x152dd8cdb5674be914a8ed5f1a3d6e6ecf777cf451b4da7f948225f95328daef));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x055ba085201335edc2baedd14b5840e3a7e22c45ea8c20dd4818fa5eacadab30), uint256(0x0f6a3aef1a1cdcb09f08f7a842db42ad7095eeac2c13935ff3a9f03a373ad3d1));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x00f43bf27b0b1ae01e429b34a3407fc9b83656ef4f27c1924db195de639ecad5), uint256(0x147beb92c32efc088496ab96663355ec4ae3e6ffa5c390f7df8967da868c38b9));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x27e74b55d22f8281e785b5a4b700e7e46e4a6c4891b782b89637d6f618aa2cd2), uint256(0x22032ceb22c9cfca43c1d1beb26613496a87b1394282df007f344b46f7a24eec));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x1f624b15946eca3671674847684ebe43a78c84b94e94cf2449aebd491ddb725f), uint256(0x28060eaab936bfaf80e8c6a16e219cf4c1dd6ce5cdb69a0465f6a0b5d844739f));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x2f13ff4d36eb3abd94f3f2161cc9bcf285178c9bee5d00e3c1dba001f6322852), uint256(0x0728a4f909415206e05c080c76c271976515211c37fda3008f37d365714400bd));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x1fb872903006da6f3ea9c4f14ed373e382570743261f720f700f2448d2ab7986), uint256(0x0628bbd393584e9c37833a11930b1c0641b98167909720ee56bf48c2c63ce72d));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x2fc7159c85b62225341fced65e1b33767489e08816ba6f6642d48acae102fee9), uint256(0x20f34f580d50db653882aa813461c48b4537ab2d2a3bba0c9fcc9ad6c52eeca0));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x1ce76533fb2e40f329442f8d60b5e8d05c58ebb4d586b64bb48a841510cff658), uint256(0x2acbd9f3e6733c46fc8a9372a4103802527064abcaf273ca4b2cabd394a46057));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x2459dcda2de2726416a34389a6119ffe546fb59b831e278c7984d262c38d768b), uint256(0x1f0a3be846ad289bc5b332f9b7aff7db0a6795e9b1a2d8b6375c1db5018974d3));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x210e9fcc6daef7ec7f8b78344b19054a8c3e227989370297399c7d518a14d6ca), uint256(0x2fa3c46001889c44b595061baa120a7c69278f2479ec0d1d9113acf6b9b66157));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x039de1b748523dcaabfff498de34b0b2c491cddc1a23cd2c1482c196f799e3a3), uint256(0x0748514fd602cab96c24d8d050321e5da76670b620eb8e062284dde5bf7043aa));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x0a2f1f9ec104727a1ddf1baa04301e8d2b016cea3f716d5d7b88c2f61daed182), uint256(0x1ac7fe170fc25ade0a0382da2ceb6f79f46a31d7e7a49ba74a82b8bf2b1a963e));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x118a3d38069c3b2775f265684ffe3ea267bfe46bb246c6e541f9fa028617f7f8), uint256(0x1dc6b07bf4f22aa8411db22faac5074ad960cd1afa7545c0dc5817c445fec70c));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x1e84be190fc2bdb18ac0e40b25c883c12a8dd611f311dc950695473efb2deceb), uint256(0x0fe366feaf4405374184bccc1523a5fd7838f9452e42a88526eeb75de41b3a3e));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x1edd4a7f294d8ee42661ba603410596cfde09bfbd1ef707ed382da1cc2c206a1), uint256(0x19c9a5a82165070dc84237944618be9d876884c255453c145aaab4a915a6610c));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x212fe7132fda6192103e1cd6826912377117f160e811a740d3fa63c4d734aa16), uint256(0x206d852d3cbbeb9ee235a5e3c24e39c6274658d99e45fddc6c4275fcb3226ae6));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x251ef23157d861efd16cd9b97b55be4c5bd18d49ac9b1b3983d3aa0e0ea82954), uint256(0x218d9e23b8b016d38c2030f75af664cbcec79d130417fb74d641f9d8bdab9c17));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x005666aa1982522dd6da5b57ed372dffa0ac5f6c7d56d56196fd438271767d3b), uint256(0x21a863ed4d84db81c92b4f781909a674987272c706aa7f0f63fa032e3aad4a04));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x0278d101140b5c392c6a73c91abf5801e8895ebc8858d9740b75f3aaa8800729), uint256(0x12bdb51734a8cb6019228cb88de515b92f0fb13e3f18fef3d0f94c3d336a26c6));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x0b40fab5e7370116a12e9c6d3c35780876e3767a388fe060983b88e0319058c4), uint256(0x143683f8c38675d84bfa568a8f6c2a24c0d9457980c7f0339b93e1a307d5b00b));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x08535e3a2e1b65aeed334e2e54ed57eec5c338fa94e2510a51503e5dfc526279), uint256(0x076b452344bc428c1f9c3bfe51fd07bfea46ef6247b64e3ba14bca3b29db03b7));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x1300dd3d2440198efcbdf92838c7f29e4a1b7687b76eccfc6a52f5b7db7cfa93), uint256(0x02b97832dd5ecbe676cbaf713e47cf4ba7e42afd547f14061695fdfefcdcc55c));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x042c293130e481cb5d48a507a97814cb86fc696e6c5ad627ee151e63dcddaa87), uint256(0x0d051dfbfaafd2d9fdd27cd1375b03d273b45e864236499cc4ce78e5b9bacda0));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x2a3b53aeb14e568a0a976dfbd09baba0e002c3ba999eeb9a87f5a7657ac95e0e), uint256(0x0975a47fe8fdd4b3c1dd5b779c52ce4b9b2de0eabc32859c5d328309fb043649));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x060c451e91b8652f2885e332f3c8e5db2509b79ee5c41c02576061432ce06992), uint256(0x1d6d063be7e21726ac34cf934119bd27df8c7e0d5cb52f77799b8406017e939e));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x17b12cc4cb4f47b4a585aec1a347324e8a827c23e6812551d1cbea5b2ab818ad), uint256(0x06007bf287852954ebebf2da25bdb7547da1a2068e0c62ede21b2bbb63d99d38));
        vk.gamma_abc[34] = Pairing.G1Point(uint256(0x25ec7ebf38e1f3d76fd2992a44ce5d9741ebf9b8543664f8d7d42209d6a11c3b), uint256(0x0b749e7f4afa71b987146f4f450f85eea5c15f880cfd6774b8cdf627fb971a97));
        vk.gamma_abc[35] = Pairing.G1Point(uint256(0x0bc057ef9c57cacf39bde392e250cb3d033acd88adbadd9d3ee773ff95093da4), uint256(0x2f70170a0ecd310bbeea3d0cd4f2a68ae49a2f2d68d68536a09c12b60c7117d3));
        vk.gamma_abc[36] = Pairing.G1Point(uint256(0x1c5b9155a8fa2fe9b2a649eec88cd47dde553dfd5f0a2e303231915f11333f08), uint256(0x0edb3085f2c5508bdd183ed5301569c53f29e4a024c0cc3b62dbf37866645d3f));
        vk.gamma_abc[37] = Pairing.G1Point(uint256(0x02186009c30355ca02d03155fe5d879856c8c304319036ada73d9ebc33bf82a9), uint256(0x06ddff68189fc5dfac3cbe0ed7a3371b9b7d8591163ff6b1e32e516a2bc5bd6a));
        vk.gamma_abc[38] = Pairing.G1Point(uint256(0x04d3d539f0153788554a42edd6ca5ddf4028b33b147456260162151950035488), uint256(0x094c5cfe8692eae072328fe2480e50c2b8d80fbdeab5ee479cf204414d45c1d3));
        vk.gamma_abc[39] = Pairing.G1Point(uint256(0x28680bf1b42e7e34a3035527e34b905a8eab6b728c78c833b511a886d0642a73), uint256(0x0aba8079dc91b53376bbe13ffd615c63e316649cc3f1c5f1e447e032e105256e));
        vk.gamma_abc[40] = Pairing.G1Point(uint256(0x11f72ad7ce5f8654794d30c32fcd683039a035677a41107259a074b8cbfa4bbb), uint256(0x27027a620258f7f20c3a4a9bdbc189663bc1b14203edcbf59d99edcea8096da4));
        vk.gamma_abc[41] = Pairing.G1Point(uint256(0x242e6631ece1c7ce0a7f63a29203eb85a3b9bd2b0b8bbcc75fcf40f81960042a), uint256(0x24981673a5914f357bc985b2952a356c04fdb46affa91bfd7edf42706e46d342));
        vk.gamma_abc[42] = Pairing.G1Point(uint256(0x1cd952577461e2368cb84ced59299c4986688a73afd47d16095e4b2a167f196d), uint256(0x269da687ceb01bb66e2a784027a058b8baa902835c5481147c14e16051fba2b1));
        vk.gamma_abc[43] = Pairing.G1Point(uint256(0x2e75e126a34c25079e9dab9624a0b09467147a308f1af1238059f406a22d4575), uint256(0x227dec7038e17c84c76ea00aee364c8aea82602a116ef9f1286eaa3ebe15103c));
        vk.gamma_abc[44] = Pairing.G1Point(uint256(0x3036ae8ca1f2ea9f422362f145753ec67d83673cd591b10f5ea7ec7036b0fa2b), uint256(0x28726649dd66290a1fd30d9181dc4a0006832953acf215437a937d2c49ac3b8e));
        vk.gamma_abc[45] = Pairing.G1Point(uint256(0x04b90d93b86eb444ea60aad5216f3ada12b5ce6461eb344d1e0941f52c9b68b8), uint256(0x219eea2cae01c34b279da23403d8fe475c665d2a78334dbebf3c572ce9b8144f));
        vk.gamma_abc[46] = Pairing.G1Point(uint256(0x169b3f7bc87efbbcac20c18db5521604610534d5cf04c12d57a8aae6b576d637), uint256(0x0ccc9318376b993d935db92c43a6fdf861739736180aa631fc8542ae6cf853f4));
        vk.gamma_abc[47] = Pairing.G1Point(uint256(0x16a5e1adea38e454c0b392b74a99db3e0d0cb970faf23db4e4738eed6fefdb4b), uint256(0x1a9cd61a6443aad98ade9a5cda53fb4c516cd24bb4a7ceb2542da98149b39bb4));
        vk.gamma_abc[48] = Pairing.G1Point(uint256(0x00ce7a6b1500fc7343ea688ce040bd03654fbf666d95944aeb0d94399648865a), uint256(0x1ea7f8e4138ce3e458360cdbf1bed1b211d528d364202ebc8086387fedf0e4d7));
        vk.gamma_abc[49] = Pairing.G1Point(uint256(0x03791ca549011f99d9e86addc61c782b96f7a497a96ee8ae98f00ec9527b914e), uint256(0x22744600740ac9ec3572d4aea12da44125fab97b41f673568765ca7dcf4874bf));
        vk.gamma_abc[50] = Pairing.G1Point(uint256(0x053d5eba04c5ba9aeeb0b8576c7baa375ca70324c329a4b49a6ea832fb7e0f55), uint256(0x2a9a0b7dca11d58b62d319d721229675b40a1ece65b35aa64a6e562ac4480adc));
        vk.gamma_abc[51] = Pairing.G1Point(uint256(0x14a937958a120b27064bd40069f03de4bdb14ff098a857a27465ddeb40ed6bd6), uint256(0x023df190007bdc6b38513cacc32a77f9a2b9c3e5109664965e2a046fcb2b985e));
        vk.gamma_abc[52] = Pairing.G1Point(uint256(0x2336125d0ff1c5298a6a8c9f352de5a83c7765c3005937975263c32fa1e0d18b), uint256(0x0f0382837e2f273c95057ff0d19e624c08ef156308190b167848300ebcbb59d0));
        vk.gamma_abc[53] = Pairing.G1Point(uint256(0x22a7a2559bab0bb2967fde14e941795d0b081315a53d320371d1ea44ea84dc8c), uint256(0x1422dec83aa539f1267a8301362e2a5ca51e54815c39e20b6325a535d66a7ace));
        vk.gamma_abc[54] = Pairing.G1Point(uint256(0x196fc5eb8a65cd8ad2bfa93383457056c49ae2ae6ff6595be0de417baaf4f5c7), uint256(0x17faa626428316f893e262fae5a9898a78f705f9ceb9a1b509c04053afa9f060));
        vk.gamma_abc[55] = Pairing.G1Point(uint256(0x1b4732d97c5d8eba7e39adcc886ef14d31b86f4b940eb1b2de3cf590505bd443), uint256(0x075badb90d816b4f455bab5be4608b0e6c242a82c8406e1d6a09ea58b5a700be));
        vk.gamma_abc[56] = Pairing.G1Point(uint256(0x1fe367bd3c0ef8dcda37e27eb1a0a75b4059971958bd19c6907e47643ab0dd5f), uint256(0x1ac3e3c1f82988464cd22c0034512a5a6d4ba59a942059441573d1df5a2d28a3));
    }
    function verify(uint[] memory input, Proof memory proof) internal view returns (uint) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.gamma_abc.length);
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++) {
            require(input[i] < snark_scalar_field);
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.gamma_abc[i + 1], input[i]));
        }
        vk_x = Pairing.addition(vk_x, vk.gamma_abc[0]);
        if(!Pairing.pairingProd4(
             proof.a, proof.b,
             Pairing.negate(vk_x), vk.gamma,
             Pairing.negate(proof.c), vk.delta,
             Pairing.negate(vk.alpha), vk.beta)) return 1;
        return 0;
    }
    function verifyTx(
            Proof memory proof, uint[56] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](56);
        
        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
    }
}
