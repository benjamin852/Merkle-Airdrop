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
