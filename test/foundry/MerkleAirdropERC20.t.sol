// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.18;

import 'forge-std/Test.sol';
import 'murky/Merkle.sol';

// import './helper/Setup.sol';

contract Setup is Test, Merkle {
    uint256 NUM_LEAVES = 1000;

    bytes32[] public merkleTreeElements;

    function setUp() public {
        Merkle m = new Merkle();

        for (uint i = 0; i < NUM_LEAVES; i++) {
            uint256 pseudoRandomAmount = uint256(
                keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))
            ) % i;
            bytes32 leafData = _hashDataForLeaf(msg.sender, pseudoRandomAmount);
            merkleTreeElements.push(leafData);
        }
    }

    function _hashDataForLeaf(
        address _recipient,
        uint256 _tokenAmount
    ) private returns (bytes32 hashedData) {
        hashedData = keccak256(abi.encodePacked(_recipient, _tokenAmount));
    }
}

contract Initialization is Test {
    function setUp() public {
        console.log('hello!');
    }

    function testShouldReturnTrue() public returns (bool) {
        return true;
    }
}
