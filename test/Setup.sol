// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.18;

import 'forge-std/Test.sol';
import 'murky/Merkle.sol';
import {FoundryRandom} from 'foundry-random/FoundryRandom.sol'; //forget test -ffi --> to allow for this script to be used
import '../contracts/mocks/MockERC20.sol';
import '../contracts/FungibleMerkleAirdrop.sol';

contract Setup is Test, Merkle, FoundryRandom {
    MockERC20 public token;

    uint256 NUM_LEAVES = 1000;

    bytes32[] public merkleTreeElements;
    bytes32 public merkleRoot;

    FungibleMerkleAirdrop merkleAirdrop;

    function setUp() public {
        Merkle m = new Merkle();

        // for (uint i = 0; i < NUM_LEAVES; i++) {
        //     uint256 pseudoRandomAmount = randomNumber(1, 10_000);
        //     bytes32 leafData = _hashDataForLeaf(msg.sender, pseudoRandomAmount);
        //     merkleTreeElements.push(leafData);
        // }

        // bytes32 root = m.getRoot(merkleTreeElements);

        // token = new MockERC20('BenERC20', 'B_ERC20', merkleRoot);

        // merkleAirdrop = new FungibleMerkleAirdrop(token, merkleRoot);
    }

    function testShouldCorrectStorageVars() public returns (bool) {
        // MockERC20 tokenFromContract = merkleAirdrop.token();
        console.log(vm.addr(1));
        assertEq(5, 5);
    }

    function _hashDataForLeaf(
        address _recipient,
        uint256 _tokenAmount
    ) private returns (bytes32 hashedData) {
        hashedData = keccak256(abi.encodePacked(_recipient, _tokenAmount));
    }
}
