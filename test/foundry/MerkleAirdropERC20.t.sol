// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.18;

import 'forge-std/Test.sol';
import './helper/Setup.sol';

contract Initialization is Setup, Test {
    function setUp() public {
        console.log('hello!');
    }

    function testShouldReturnTrue() public returns (bool) {
        return true;
    }
}
