// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console.sol";

contract Verifier {

    // Useful precompile addresses
    uint256 constant precompile_modexp = 0x05;
    uint256 constant precompile_add = 0x06;
    uint256 constant precompile_mul = 0x07;
    uint256 constant precompile_verify = 0x08;

    // Base Field modulus
    // uint256 constant t = 4965661367192848881;
    // uint256 constant p = 36*t**4 + 36*t**3 + 24*t**2 + 6*t + 1;
    uint256 constant p = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    // Useful exponents in F1
    // uint256 constant exp_inverse = p - 2;
    // uint256 constant exp_sqrt = (p + 1) / 4;
    uint256 constant exp_inverse = 21888242871839275222246405745257275088696311157297823662689037894645226208581;
    uint256 constant exp_sqrt = 5472060717959818805561601436314318772174077789324455915672259473661306552146;

    // Useful constants in F1
    uint256 constant constant_1_2 = 0x183227397098d014dc2822db40c0ac2ecbc0b548b438e5469e10460b6c3e7ea4;
    uint256 constant constant_27_82 = 0x2b149d40ceb8aaae81be18991be06ac3b5b4c5e559dbefa33267e6dc24a138e5;
    uint256 constant constant_3_82 = 0x2fcd3ac2a640a154eb23960892a85a68f031ca0c8344b23a577dcf1052b9e775;

    // Alpha point in G1
    uint256 constant alpha_x = 20491192805390485299153009773594534940189261866228447918068658471970481763042;
    uint256 constant alpha_y = 9383485363053290200918347156157836566562967994039712273449902621266178545958;

    // Beta point in G2 in powers of i
    uint256 constant beta_x_1 = 4252822878758300859123897981450591353533073413197771768651442665752259397132;
    uint256 constant beta_x_0 = 6375614351688725206403948262868962793625744043794305715222011528459656738731;
    uint256 constant beta_y_1 = 21847035105528745403288232691147584728191162732299865338377159692350059136679;
    uint256 constant beta_y_0 = 10505242626370262277552901082094356697409835680220590971873171140371331206856;

    // Gamma point in G2 in powers of i
    uint256 constant gamma_x_1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant gamma_x_0 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 constant gamma_y_1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant gamma_y_0 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;

    // Delta point in G2 in powers of i
    uint256 constant delta_x_1 = 18976133691706015337908381757202123182841901611067930614519324084182946094218;
    uint256 constant delta_x_0 = 1382518990777992893805140303684642328066746531257780279226677247567004248173;
    uint256 constant delta_y_1 = 6627710380771660558660627878547223719795356903257079198333641681330388499309;
    uint256 constant delta_y_0 = 21806956747910197517744499423107239699428979652113081469385876768212706694581;

    // Public input points in G1
    uint256 constant constant_one_x = 19918517214839406678907482305035208173510172567546071380302965459737278553528;
    uint256 constant constant_one_y = 7151186077716310064777520690144511885696297127165278362082219441732663131220;
    uint256 constant merkle_tree_root_x = 690581125971423619528508316402701520070153774868732534279095503611995849608;
    uint256 constant merkle_tree_root_y = 21271996888576045810415843612869789314680408477068973024786458305950370465558;
    uint256 constant nullifier_hash_x = 16461282535702132833442937829027913110152135149151199860671943445720775371319;
    uint256 constant nullifier_hash_y = 2814052162479976678403678512565563275428791320557060777323643795017729081887;
    uint256 constant signal_x = 4319780315499060392574138782191013129592543766464046592208884866569377437627;
    uint256 constant signal_y = 13920930439395002698339449999482247728129484070642079851312682993555105218086;
    uint256 constant external_nullifier_x = 3554830803181375418665292545416227334138838284686406179598687755626325482686;
    uint256 constant external_nullifier_y = 5951609174746846070367113593675211691311013364421437923470787371738135276998;

    function negate(uint256 a) public pure returns (uint256 x) {
        x = (p - a) % p; // Modulo is cheaper than branching
    }

    function exp(uint256 a, uint256 e) public view returns (uint256 x) {
        bool success;
        assembly {
            let f := mload(0x40)
            mstore(f, 0x20)
            mstore(add(f, 0x20), 0x20)
            mstore(add(f, 0x40), 0x20)
            mstore(add(f, 0x60), a)
            mstore(add(f, 0x80), e)
            mstore(add(f, 0xa0), p)
            success := staticcall(sub(gas(), 2000), precompile_modexp, f, 0xc0, f, 0x20)
            x := mload(f)
        }
        require(success);
    }

    function invert(uint256 a) public view returns (uint256 x) {
        x = exp(a, exp_inverse);
        require(mulmod(a, x, p) == 1);
    }

    function sqrt(uint256 a) public view returns (uint256 x) {
        x = exp(a, exp_sqrt);
        require(mulmod(x, x, p) == a);
    }

    function sqrt_f2(uint256 a0, uint256 a1, bool hint) public view returns (uint256 x0, uint256 x1) {
        uint256 d = sqrt(addmod(mulmod(a0, a0, p), mulmod(a1, a1, p), p));
        if (hint) {
            d = negate(d);
        }
        x0 = sqrt(mulmod(addmod(a0, d, p), constant_1_2, p));
        x1 = mulmod(a1, invert(mulmod(x0, 2, p)), p);

        require(a0 == addmod(mulmod(x0, x0, p), negate(mulmod(x1, x1, p)), p));
        require(a1 == mulmod(2, mulmod(x0, x1, p), p));
    }

    function decompress_g1(uint256 c) public view returns (uint256 x, uint256 y) {
        bool is_odd = c & 1 == 1;
        x = c >> 1;
        y = sqrt(mulmod(mulmod(x, x, p), x, p) + 3);
        if (is_odd && y & 1 == 0) {
            y = negate(y);
        }
    }

    function decompress_g2(uint256 c0, uint256 c1) public view returns (uint256 x0, uint256 x1, uint256 y0, uint256 y1) {
        bool is_odd = c0 & 1 == 1;
        bool hint = c0 & 2 == 2;
        x0 = c0 >> 2;
        x1 = c1;

        uint256 n3ab = mulmod(mulmod(x0, x1, p), p-3, p);
        uint256 a_3 = mulmod(mulmod(x0, x0, p), x0, p);
        uint256 b_3 = mulmod(mulmod(x1, x1, p), x1, p);

        y0 = addmod(constant_27_82, addmod(a_3, mulmod(n3ab, x1, p), p), p);
        y1 = negate(addmod(constant_3_82,  addmod(b_3, mulmod(n3ab, x0, p), p), p));

        (y0, y1) = sqrt_f2(y0, y1, hint);
        if (is_odd && y0 & 1 == 0) {
            y0 = negate(y0);
            y1 = negate(y1);
        }
    }

    function add(uint256 a_x, uint256 a_y, uint256 b_x, uint256 b_y) public view returns (uint256 x, uint256 y) {
        bool success;
        assembly {
            let f := mload(0x40)
            mstore(f, a_x)
            mstore(add(f, 0x20), a_y)
            mstore(add(f, 0x40), b_x)
            mstore(add(f, 0x60), b_y)
            success := staticcall(sub(gas(), 2000), precompile_add, f, 0x80, f, 0x40)
            x := mload(f)
            y := mload(add(f, 0x20))
        }
        require(success);
    }

    function mul(uint256 a_x, uint256 a_y, uint256 s) public view returns (uint256 x, uint256 y) {
        bool success;
        assembly {
            let f := mload(0x40)
            mstore(f, a_x)
            mstore(add(f, 0x20), a_y)
            mstore(add(f, 0x40), s)
            success := staticcall(sub(gas(), 2000), precompile_mul, f, 0x60, f, 0x40)
            x := mload(f)
            y := mload(add(f, 0x20))
        }
        require(success);
    }

    // Returns a + s ⋅ b with a,b in G1 and s in F1
    // See https://eips.ethereum.org/EIPS/eip-196
    // Note: the curve points are verified, but `s` is not.
    function muladd(uint256 a_x, uint256 a_y, uint256 b_x, uint256 b_y,uint256 s) public view returns (uint256 x, uint256 y) {
        (x, y) = mul(b_x, b_y, s);
        (x, y) = add(a_x, a_y, x, y);
    }

    function verifyCompressedProof(
        uint256 merkleTreeRoot,
        uint256 nullifierHash,
        uint256 signalHash,
        uint256 externalNullifierHash,
        uint256[4] calldata compressedProof
    ) public view {
        uint256[8] memory proof;
        (uint256 x, uint256 y) = decompress_g1(compressedProof[0]); // A
        proof[0] = x;
        proof[1] = y;

        (uint256 x0, uint256 x1, uint256 y0, uint256 y1) = decompress_g2(compressedProof[2], compressedProof[1]); // B

        proof[2] = x1;
        proof[3] = x0;
        proof[4] = y1;
        proof[5] = y0;
        
        (x,y) = decompress_g1(compressedProof[3]); // C
        proof[6] = x;
        proof[7] = y;

        verifyProof(merkleTreeRoot, nullifierHash, signalHash, externalNullifierHash, proof);
    }

    function verifyProof(
        uint256 merkleTreeRoot,
        uint256 nullifierHash,
        uint256 signalHash,
        uint256 externalNullifierHash,
        uint256[8] memory proof
    ) public view {
        // Compute the public input linear combination
        uint256 x;
        uint256 y;
        (x, y) = (constant_one_x, constant_one_y);
        (x, y) = muladd(x, y, merkle_tree_root_x, merkle_tree_root_y, merkleTreeRoot);
        (x, y) = muladd(x, y, nullifier_hash_x, nullifier_hash_y, nullifierHash);
        (x, y) = muladd(x, y, signal_x, signal_y, signalHash);
        (x, y) = muladd(x, y, external_nullifier_x, external_nullifier_y, externalNullifierHash);

        // TODO: Public input is not checked for being in reduced form.
        // OPT: Statically negate beta, gamma, delta instead of proof[1].
        // OPT: Calldatacopy proof to input. Swap pairings so proof is contiguous.
        // OPT: Codecopy remaining points except (x, y) to input.

        // Verify the pairing
        // Note that the precompile expects the F2 coefficients in reverse order.
        uint256[24] memory input;
        // e(-A, B)
        input[ 0] = proof[0]; // A_x
        input[ 1] = negate(proof[1]); // A_y
        input[ 2] = proof[2]; // B_x_1
        input[ 3] = proof[3]; // B_x_0
        input[ 4] = proof[4]; // B_y_1
        input[ 5] = proof[5]; // B_y_0
        // e(α, β)
        input[ 6] = alpha_x;
        input[ 7] = alpha_y;
        input[ 8] = beta_x_1;
        input[ 9] = beta_x_0;
        input[10] = beta_y_1;
        input[11] = beta_y_0;
        // e(γ, δ)
        input[12] = x;
        input[13] = y;
        input[14] = gamma_x_1;
        input[15] = gamma_x_0;
        input[16] = gamma_y_1;
        input[17] = gamma_y_0;
        // e(C, δ)
        input[18] = proof[6]; // C_x
        input[19] = proof[7]; // C_y
        input[20] = delta_x_1;
        input[21] = delta_x_0;
        input[22] = delta_y_1;
        input[23] = delta_y_0;
        bool success;
        uint256[1] memory output;
        assembly {
            success := staticcall(sub(gas(), 2000), precompile_verify, input, 0x300, output, 0x20)
        }
        require(success);
        require(output[0] == 1);
    }
}
