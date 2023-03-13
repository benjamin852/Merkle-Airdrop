// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IERC20, SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/utils/structs/BitMaps.sol';
import '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';
import './mocks/MockNft.sol';

error AlreadyClaimed(uint256 tokenId);
error InvalidProof();

contract MerkleAirdrop {
    using SafeERC20 for IERC20;
    using BitMaps for BitMaps.BitMap;

    MockNft public immutable token;
    bytes32 public immutable merkleRoot;

    BitMaps.BitMap private claimedBitMap;

    /** EVENTS **/
    event Claimed(uint256 index, address account, uint256 amount);
    event ClaimedNft(uint256 index, address account, uint256 tokenId);

    constructor(MockNft token_, bytes32 merkleRoot_) {
        token = token_;
        merkleRoot = merkleRoot_;
    }

    function isClaimed(uint256 index) public view returns (bool) {
        return claimedBitMap.get(index);
    }

    function _setClaimed(uint256 index) private {
        claimedBitMap.set(index);
    }

    function claim(uint256 index, address account, bytes32[] calldata merkleProof) public virtual {
        if (isClaimed(index)) revert AlreadyClaimed(index);

        // Verify the merkle proof.
        bytes32 node = keccak256(abi.encodePacked(index, account));
        if (!MerkleProof.verify(merkleProof, merkleRoot, node)) revert InvalidProof();

        // Mark it claimed and send the token.
        _setClaimed(index);

        // IERC20(token).safeTransfer(account, amount);
        token.redeem(account, index, merkleProof);

        // emit Claimed(index, account, amount);
    }
}
