// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import '@openzeppelin/contracts/utils/structs/BitMaps.sol';
import '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';
import './mocks/MockNft.sol';

error AlreadyClaimed();
error InvalidProof();

contract NFTMerkleAirdrop {
    /** LIBRARIES **/
    using BitMaps for BitMaps.BitMap;

    /** STORAGE **/
    MockNft public immutable token;
    bytes32 public immutable merkleRoot;

    BitMaps.BitMap private claimedBitMap;

    /** EVENTS **/
    event ClaimedNft(uint256 tokenId, address account);

    /** CONSTRUCTOR **/
    constructor(MockNft _token, bytes32 _merkleRoot) {
        token = _token;
        merkleRoot = _merkleRoot;
    }

    /** FUNCTIONS **/

    /**
     * @notice checks bitMap to see if token claimed
     * @param _tokenId the token being checked
     * @return claimed bool if token is claimed
     */
    function isClaimed(uint256 _tokenId) public view returns (bool claimed) {
        claimed = claimedBitMap.get(_tokenId);
    }

    /**
     * @notice sets bitMap for a claimed token
     * @param _tokenId _tokenId to set claimed
     */
    function _setClaimed(uint256 _tokenId) private {
        claimedBitMap.set(_tokenId);
    }

    /**
     * @notice claims a token
     * @param _tokenId the token that is being claimed
     * @param _account the account claiming the token
     * @param _merkleProof  the proof used to claim the token
     */
    function claim(uint256 _tokenId, address _account, bytes32[] calldata _merkleProof) external {
        if (isClaimed(_tokenId)) revert AlreadyClaimed();

        // Verify the merkle proof.
        bytes32 leaf = keccak256(abi.encodePacked(_tokenId, _account));
        if (!MerkleProof.verify(_merkleProof, merkleRoot, leaf)) revert InvalidProof();

        // Mark it claimed and send the token.
        _setClaimed(_tokenId);

        token.redeem(_account, _tokenId, _merkleProof);

        emit ClaimedNft(_tokenId, _account);
    }
}
