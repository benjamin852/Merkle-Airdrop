// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.18;

import 'forge-std/Test.sol';

// import './helper/Setup.sol';

contract Setup is Test {
    uint256 NUM_LEAVES = 1000;

    bytes32 public leafData;

    function setUp() public {
        Merkle m = new Merkle();

        for (uint i = 0; i < NUM_LEAVES; i++) {}
    }

    function _hashDataForLeaf(
        address _recipient,
        uint256 _tokenAmount
    ) private returns (bytes32 hashedData) {
        hashedData = keccak256(_recipent, _tokenAmount);
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
