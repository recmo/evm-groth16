// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/Verifier.sol";

contract TestVerifier {
    Verifier public verifier;

    function setUp() public {
        verifier = new Verifier();
    }

    function testVerifyCompressedProof() public {
        verifier.verifyCompressedProof(
            0x0190a04b0b6bc5b1aa7f21bd71af791a153c55f03525b0e8f016e0509ff4c5ff, // merkleTreeRoot
            0x16a35d28cbd6cf723515e2c4e7bb7a0c721c6c4ce4ba49d57afe2deccbf9b81a, // nullifierHash
            0x00405787fa12a823e0f2b7631cc41b3ba8828b3321ca811111fa75cd3aa3bb5a, // signalHash
            0x00509a96d32fe5d81bee660704a0a9cc737b8325af925d6adb9e42b7ae816cad, // externalNullifierHash
            [
                0x26bbb723f965460ca7282cd75f0e3e7c67b15817f7cee60856b394936ed02917 << 1,
                // 0x20a5c7381abf89a874a730813c75acf156539c039fbb600449461df278ea7a68,
                0x13cd4f0451538ece5014fe6688b197aefcc611a5c6a7c319f834f2188ba04b08,
                0x126ff07e81490a1b6ae92b2d9e700c8e23e9d5c7f6ab857027213819a6c9ae7d,
                0x04183624c9858a56c54deb237c26cb4355bc2551312004e65fc5b299440b15a3,
                0x2e4b11aa549ad6c667057b18be4f4437fda92f018a59430ebb992fa3462c9ca1,
                0x2dde6d7baf0bfa09329ec8d44c38282f5bf7f9ead1914edd7dcaebb498c84519 << 1 | 1
                // 0x0c359f868a85c6e6c1ea819cfab4a867501a3688324d74df1fe76556558b1937
            ]
        );
    }

    function testVerifyProof() public {
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
