# Groth16 verifier in EVM

Using point compression as described in [2π.com/23/bn254-compression](https://2π.com/23/bn254-compression).

Build using [Foundry]'s `forge`

[Foundry]: https://book.getfoundry.sh/reference/forge/forge-build


```sh
forge build
forge test --gas-report
```

Gas usage:

```
| src/Verifier.sol:Verifier contract |                 |        |        |        |         |
|------------------------------------|-----------------|--------|--------|--------|---------|
| Deployment Cost                    | Deployment Size |        |        |        |         |
| 768799                             | 3872            |        |        |        |         |
| Function Name                      | min             | avg    | median | max    | # calls |
| decompress_g1                      | 2390            | 2390   | 2390   | 2390   | 1       |
| decompress_g2                      | 7605            | 7605   | 7605   | 7605   | 1       |
| invert                             | 2089            | 2089   | 2089   | 2089   | 1       |
| sqrt                               | 2056            | 2056   | 2056   | 2056   | 1       |
| sqrt_f2                            | 6637            | 6637   | 6637   | 6637   | 1       |
| verifyCompressedProof              | 221931          | 221931 | 221931 | 221931 | 1       |
| verifyProof                        | 210565          | 210565 | 210565 | 210565 | 1       |


| test/Reference.t.sol:Reference contract |                 |        |        |        |         |
|-----------------------------------------|-----------------|--------|--------|--------|---------|
| Deployment Cost                         | Deployment Size |        |        |        |         |
| 6276333                                 | 14797           |        |        |        |         |
| Function Name                           | min             | avg    | median | max    | # calls |
| verifyProof                             | 280492          | 280492 | 280492 | 280492 | 1       |
```
