// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.18;

import 'forge-std/Test.sol';
import 'murky/Merkle.sol';
// import {FoundryRandom} from 'foundry-random/FoundryRandom.sol'; //forge test --ffi
import '../contracts/mocks/MockERC20.sol';
import '../contracts/FungibleMerkleAirdrop.sol';

contract Setup is Test, Merkle {
    MockERC20 public token;

    uint256 NUM_LEAVES = 500;

    bytes32[] public merkleTreeElements;
    bytes32 public merkleRoot;

    FungibleMerkleAirdrop merkleAirdrop;

    Merkle public m;

    function setUp() public {
        m = new Merkle();
        for (uint i = 0; i < NUM_LEAVES; i++) {
            //unsure how to claim a random amount
            // uint256 pseudoRandomAmount = randomNumber(1, 10_000);
            bytes32 leafData = _hashDataForLeaf(i, vm.addr(1), 100);
            merkleTreeElements.push(leafData);
        }

        merkleRoot = m.getRoot(merkleTreeElements);

        token = new MockERC20('BenERC20', 'B_ERC20', merkleRoot);

        merkleAirdrop = new FungibleMerkleAirdrop(token, merkleRoot);
    }

    function _hashDataForLeaf(
        uint256 _index,
        address _recipient,
        uint256 _tokenAmount
    ) internal pure returns (bytes32 hashedData) {
        hashedData = keccak256(abi.encodePacked(_index, _recipient, _tokenAmount));
    }
}
