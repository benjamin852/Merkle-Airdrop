// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.18;

import 'forge-std/Test.sol';
import './Setup.sol';

contract Constructor is Setup {
    function testShouldSetCorrectToken() public {
        MockERC20 tokenFromContract = merkleAirdrop.token();
        assertEq(address(tokenFromContract), address(token));
    }

    function testShouldSetCorrectMerkleRoot() public {
        bytes32 merkleRootFromContract = merkleAirdrop.merkleRoot();
        assertEq(merkleRootFromContract, merkleRoot);
    }
}

contract Claimed is Setup {
    function testFuzz_ShouldSetClaimed(uint8 amount) public {
        vm.assume(amount > 0);
        bool isClaimedBefore = merkleAirdrop.isClaimed(amount);
        assertFalse(isClaimedBefore);
        merkleAirdrop.setClaimed(amount);
        bool isClaimed = merkleAirdrop.isClaimed(amount);
        assertTrue(isClaimed);
    }
}

contract ClaimFungibleToken is Setup {
    function testFuzz_ShouldRevertIfClaimedTwice() public {
        // vm.assume(index > 0);
        // merkleAirdrop.setClaimed(11);
        bytes32 leafData = _hashDataForLeaf(11, vm.addr(1), 100);
        bytes32[] memory proof = m.getProof(merkleTreeElements, 11);

        bool testMe = m.verifyProof(merkleRoot, proof, leafData);
        assertTrue(testMe);

        // merkleAirdrop.claimFungibleToken(vm.addr(1), 100, 11, proof);
    }

    function testShouldSetClaimed() public {}

    function testShouldRevertIfInvalidProof() public {}

    function testShouldTransferTokenToClaimer() public {}

    function testShouldEmitTokenClaimedEvent() public {}
}
