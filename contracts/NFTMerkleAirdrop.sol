// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IERC20, SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import '@openzeppelin/contracts/utils/structs/BitMaps.sol';
import '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';
import './mocks/MockNft.sol';

error AlreadyClaimed();
error InvalidProof();

contract NFTMerkleAirdrop {
    /** LIBRARIES **/
    using SafeERC20 for IERC20;
    using BitMaps for BitMaps.BitMap;

    /** GENERAL STORAGE VARS **/
    MockNft public immutable token;
    bytes32 public immutable merkleRoot;

    BitMaps.BitMap private claimedBitMap;

    /** EVENTS **/
    event ClaimedNft(uint256 tokenId, address account);

    /** CONSTRUCTOR **/
    constructor(MockNft token_, bytes32 merkleRoot_) {
        token = token_;
        merkleRoot = merkleRoot_;
    }

    /** FUNCTIONS **/

    /**
     * @notice checks bitMap to see if token claimed
     * @param tokenId the token being checked
     * @return claimed bool if token is claimed
     */
    function isClaimed(uint256 tokenId) public view returns (bool claimed) {
        claimed = claimedBitMap.get(tokenId);
    }

    /**
     * @notice sets bitMap for a claimed token
     * @param tokenId tokenId to set claimed
     */
    function _setClaimed(uint256 tokenId) private {
        claimedBitMap.set(tokenId);
    }

    /**
     * @notice claims a token
     * @param tokenId the token that is being claimed
     * @param account the account claiming the token
     * @param merkleProof  the proof used to claim the token
     */
    function claim(
        uint256 tokenId,
        address account,
        bytes32[] calldata merkleProof
    ) external virtual {
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
