// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';

contract MockNft is ERC721 {
    bytes32 public immutable root;

    constructor(string memory name, string memory symbol, bytes32 merkleroot) ERC721(name, symbol) {
        root = merkleroot;
    }

    /**
     * @notice redeem the NFT if the NFT is contained in the merkle tree
     * @param _account the account that owns the token
     * @param _tokenId the id of the nft to be redeemed
     * @param _proof the proof used to redeem the token
     */
    function redeem(address _account, uint256 _tokenId, bytes32[] calldata _proof) external {
        require(_verify(_leaf(_account, _tokenId), _proof), 'Invalid merkle proof');
        _safeMint(_account, _tokenId);
    }

    /**
     * @notice gets leaf at the bottom of the tree
     * @param _account the account contained in the leaf
     * @param _tokenId the id contained in the leaf
     * @return leaf the leaf itself as a hash
     */
    function _leaf(address _account, uint256 _tokenId) internal pure returns (bytes32 leaf) {
        leaf = keccak256(abi.encodePacked(_tokenId, _account));
    }

    /**
     * @notice verify the the leaf is contained in the tree
     * @param _leafParam the leaf passed in
     * @param _proof the proof being used to verify the validity of the leaf in the tree
     * @return isVerified a bool of whether the leaf is verified
     */
    function _verify(
        bytes32 _leafParam,
        bytes32[] memory _proof
    ) internal view returns (bool isVerified) {
        isVerified = MerkleProof.verify(_proof, root, leafParam);
    }
}
