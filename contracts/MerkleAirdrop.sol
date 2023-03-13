// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IERC20, SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/utils/structs/BitMaps.sol';
import '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';
import './mocks/MockNft.sol';

error AlreadyClaimed();
error InvalidProof();

contract MerkleAirdrop {
    using SafeERC20 for IERC20;
    using BitMaps for BitMaps.BitMap;

    MockNft public immutable token;
    bytes32 public immutable merkleRoot;

    BitMaps.BitMap private claimedBitMap;

    /** EVENTS **/
    // event Claimed(uint256 tokenId, address account, uint256 amount);
    event ClaimedNft(uint256 tokenId, address account);

    constructor(MockNft token_, bytes32 merkleRoot_) {
        token = token_;
        merkleRoot = merkleRoot_;
    }

    function isClaimed(uint256 tokenId) public view returns (bool) {
        return claimedBitMap.get(tokenId);
    }

    function _setClaimed(uint256 tokenId) private {
        claimedBitMap.set(tokenId);
    }

    function claim(
        uint256 tokenId,
        address account,
        bytes32[] calldata merkleProof
    ) public virtual {
        if (isClaimed(tokenId)) revert AlreadyClaimed();

        // Verify the merkle proof.
        bytes32 leaf = keccak256(abi.encodePacked(tokenId, account));
        if (!MerkleProof.verify(merkleProof, merkleRoot, leaf)) revert InvalidProof();

        // Mark it claimed and send the token.
        _setClaimed(tokenId);

        // IERC20(token).safeTransfer(account, amount);
        token.redeem(account, tokenId, merkleProof);

        emit ClaimedNft(tokenId, account);
    }
}
