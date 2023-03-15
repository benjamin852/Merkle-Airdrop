// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';

contract MockERC20 is ERC20 {
    bytes32 public immutable root;

    constructor(
        string memory name,
        string memory symbol,
        uint256 _amountToMint,
        bytes32 merkleRoot
    ) ERC20(name, symbol) {
        root = merkleRoot;
        _mint(msg.sender, _amountToMint);
    }

    /**
     * @notice redeem the token for the airdrop recipient
     * @param account the account redeeming the token
     * @param amount the amount of tokens being redeemed
     * @param proof the proof for the leaf existing in the merkle tree
     */
    function redeem(address account, uint256 amount, bytes32[] calldata proof) external {
        require(_verify(_leaf(account, amount), proof), 'Invalid merkle proof');
    }

    /**
     * @notice the leaf in the tree containing the token&recipient receiving the airdrop
     * @param _account the account contained in the leaf
     * @param _amount the amount of tokens in the leaf
     * @return leaf the hashed leaf
     */
    function _leaf(address _account, uint256 _amount) internal pure returns (bytes32 leaf) {
        leaf = keccak256(abi.encode(_account, _amount));
    }

    /**
     * @notice verify the leaf is contained in the tree
     * @param _leafParam the leaf passed in
     * @param proof the proof being used to verify the validity of the tree
     * @return isVerified a bool of whether the leaf is verified
     */
    function _verify(
        bytes32 _leafParam,
        bytes32[] memory proof
    ) internal view returns (bool isVerified) {
        isVerified = MerkleProof.verify(proof, root, _leafParam);
    }
}
