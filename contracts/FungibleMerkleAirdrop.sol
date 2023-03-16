// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import '@openzeppelin/contracts/utils/structs/BitMaps.sol';
import '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';
import '../contracts/mocks/MockERC20.sol';

// /** ERRORS **/
error AlreadyClaimed();
error InvalidProof();

contract FungibleMerkleAirdrop {
    /** LIBRARIES **/
    using BitMaps for BitMaps.BitMap;

    /** STORAGE **/
    MockERC20 public immutable token;
    bytes32 public immutable merkleRoot;

    BitMaps.BitMap private claimedBitMap;

    /** EVENTS **/
    event TokenClaimed(address claimer, uint256 tokenAmount);

    /** CONSTRUCTOR **/
    constructor(MockERC20 _token, bytes32 _merkleRoot) {
        token = _token;
        merkleRoot = _merkleRoot;
    }

    /** FUNCTIONS **/

    /**
     *
     * @param _index the index of the token in the bitmap
     * @return claimed bool if token is claimed
     */
    function isClaimed(uint256 _index) public view returns (bool claimed) {
        claimed = claimedBitMap.get(_index);
    }

    /**
     * @notice set the token status to claimed in the merkle tree
     * @param _index the token index in the bitmap being claimed
     */
    function setClaimed(uint256 _index) public {
        claimedBitMap.set(_index);
    }

    /**
     * @notice claim erc20 token
     * @param _claimer the redeeming address claiming the token
     * @param _amount the amount of tokens being claimed
     * @param _index the index of the token in the bitmap being claimed
     * @param _merkleProof the proof used to claim the token
     */
    function claimFungibleToken(
        address _claimer,
        uint256 _amount,
        uint256 _index,
        bytes32[] calldata _merkleProof
    ) external {
        //check if claimed
        if (isClaimed(_index)) revert AlreadyClaimed();

        //claim token
        setClaimed(_index);

        //verify merkle proof
        bytes32 leaf = keccak256(abi.encodePacked(_index, _claimer, _amount));
        if (!MerkleProof.verify(_merkleProof, merkleRoot, leaf)) revert InvalidProof();

        //mint my rewards
        // token.redeem(_claimer, _amount, _merkleProof);

        emit TokenClaimed(_claimer, _amount);
    }
}
