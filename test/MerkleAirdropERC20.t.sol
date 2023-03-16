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
    function testFuzz_ShouldRevertIfClaimedTwice(uint8 index) public {
        vm.assume(index > 0);
        merkleAirdrop.setClaimed(index);

        bytes32[] memory proof = m.getProof(merkleTreeElements, index);

        vm.expectRevert(AlreadyClaimed.selector);
        merkleAirdrop.claimFungibleToken(vm.addr(1), 100, index, proof);
    }

    function testFuzz_ShouldSetClaimed(uint8 index) public {
        vm.assume(index > 0);

        bool checkClaimed = merkleAirdrop.isClaimed(index);
        assertFalse(checkClaimed);

        bytes32[] memory proof = m.getProof(merkleTreeElements, index);

        bytes32 leafData = _hashDataForLeaf(index, vm.addr(1), 100);

        bool proofIsVerified = m.verifyProof(merkleRoot, proof, leafData);
        assertTrue(proofIsVerified);

        merkleAirdrop.claimFungibleToken(vm.addr(1), 100, index, proof);
        bool checkClaimedAfter = merkleAirdrop.isClaimed(index);
        assertTrue(checkClaimedAfter);
    }

    function testShouldRevertIfInvalidProof() public {}

    function testShouldTransferTokenToClaimer() public {}

    function testShouldEmitTokenClaimedEvent() public {}
}
