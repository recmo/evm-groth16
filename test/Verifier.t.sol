// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/Verifier.sol";

contract TestVerifier {
    Verifier public verifier;

    function setUp() public {
        verifier = new Verifier();
    }

    function testInvert() public view {
        uint256 a = verifier.invert(
            4598362786468342265918458423096940256393720972438048893356218087518821823203
        );
        require(a == 4182222526301715069940346543278816173622053692765626450942898397518664864041);
    }

    function testSqrt() public view {
        uint256 a = verifier.sqrt(
            14471043194638943579446425262583282548539507047061604313953794288955195726209
        );
        require(a == 13741342543520938546471415319044405232187715299443307089577869276344592329757);
    }

    function testSqrtF2() public view {
        (uint256 a, uint256 b) = verifier.sqrt_f2(
            17473058728477435457299093362519578563618705081729024467362715416915525458528,
            17683468329848516541101685027677188007795188556813329975791177956431310972350,
            false
        );
        require(a == 10193706077588260514783319931179623845729747565730309463634080055351233087269);
        require(b == 2911435556167431587172450261242327574185987927358833959334220021362478804490);
    }

    function testDecompressG1() public view {
        (uint256 x, uint256 y) = verifier.decompress_g1(
            0x26bbb723f965460ca7282cd75f0e3e7c67b15817f7cee60856b394936ed02917 << 1
        );
        require(x == 0x26bbb723f965460ca7282cd75f0e3e7c67b15817f7cee60856b394936ed02917);
        require(y == 0x20a5c7381abf89a874a730813c75acf156539c039fbb600449461df278ea7a68);
    }

    function testDecompressG2() public view {
        (uint256 x0, uint256 x1, uint256 y0, uint256 y1) = verifier.decompress_g2(
            0x126ff07e81490a1b6ae92b2d9e700c8e23e9d5c7f6ab857027213819a6c9ae7d << 2 | 0,
            0x13cd4f0451538ece5014fe6688b197aefcc611a5c6a7c319f834f2188ba04b08
        );
        require(x0 == 0x126ff07e81490a1b6ae92b2d9e700c8e23e9d5c7f6ab857027213819a6c9ae7d);
        require(x1 == 0x13cd4f0451538ece5014fe6688b197aefcc611a5c6a7c319f834f2188ba04b08);
        require(y0 == 0x2e4b11aa549ad6c667057b18be4f4437fda92f018a59430ebb992fa3462c9ca1);
        require(y1 == 0x04183624c9858a56c54deb237c26cb4355bc2551312004e65fc5b299440b15a3);
    }

    function testVerifyCompressedProof() public view {
        verifier.verifyCompressedProof(
            0x0190a04b0b6bc5b1aa7f21bd71af791a153c55f03525b0e8f016e0509ff4c5ff, // merkleTreeRoot
            0x16a35d28cbd6cf723515e2c4e7bb7a0c721c6c4ce4ba49d57afe2deccbf9b81a, // nullifierHash
            0x00405787fa12a823e0f2b7631cc41b3ba8828b3321ca811111fa75cd3aa3bb5a, // signalHash
            0x00509a96d32fe5d81bee660704a0a9cc737b8325af925d6adb9e42b7ae816cad, // externalNullifierHash
            [
                0x26bbb723f965460ca7282cd75f0e3e7c67b15817f7cee60856b394936ed02917 << 1,
                // 0x20a5c7381abf89a874a730813c75acf156539c039fbb600449461df278ea7a68,
                0x13cd4f0451538ece5014fe6688b197aefcc611a5c6a7c319f834f2188ba04b08,
                0x126ff07e81490a1b6ae92b2d9e700c8e23e9d5c7f6ab857027213819a6c9ae7d << 2 | 0,
                // 0x04183624c9858a56c54deb237c26cb4355bc2551312004e65fc5b299440b15a3,
                // 0x2e4b11aa549ad6c667057b18be4f4437fda92f018a59430ebb992fa3462c9ca1,
                0x2dde6d7baf0bfa09329ec8d44c38282f5bf7f9ead1914edd7dcaebb498c84519 << 1 | 1
                // 0x0c359f868a85c6e6c1ea819cfab4a867501a3688324d74df1fe76556558b1937
            ]
        );
    }

    function testVerifyProof() public view {
        verifier.verifyProof(
            0x0190a04b0b6bc5b1aa7f21bd71af791a153c55f03525b0e8f016e0509ff4c5ff, // merkleTreeRoot
            0x16a35d28cbd6cf723515e2c4e7bb7a0c721c6c4ce4ba49d57afe2deccbf9b81a, // nullifierHash
            0x00405787fa12a823e0f2b7631cc41b3ba8828b3321ca811111fa75cd3aa3bb5a, // signalHash
            0x00509a96d32fe5d81bee660704a0a9cc737b8325af925d6adb9e42b7ae816cad, // externalNullifierHash
            [
                0x26bbb723f965460ca7282cd75f0e3e7c67b15817f7cee60856b394936ed02917,
                0x20a5c7381abf89a874a730813c75acf156539c039fbb600449461df278ea7a68,
                0x13cd4f0451538ece5014fe6688b197aefcc611a5c6a7c319f834f2188ba04b08,
                0x126ff07e81490a1b6ae92b2d9e700c8e23e9d5c7f6ab857027213819a6c9ae7d,
                0x04183624c9858a56c54deb237c26cb4355bc2551312004e65fc5b299440b15a3,
                0x2e4b11aa549ad6c667057b18be4f4437fda92f018a59430ebb992fa3462c9ca1,
                0x2dde6d7baf0bfa09329ec8d44c38282f5bf7f9ead1914edd7dcaebb498c84519,
                0x0c359f868a85c6e6c1ea819cfab4a867501a3688324d74df1fe76556558b1937
            ]
        );
    }
}
