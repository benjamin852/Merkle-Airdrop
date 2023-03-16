// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.18;

import 'forge-std/Test.sol';
import './Setup.sol';

contract Constructor is Setup {
    function testShouldCorrectStorageVars() public {
        MockERC20 tokenFromContract = merkleAirdrop.token();
        assertEq(address(tokenFromContract), address(token));
    }
}
