//FOR NFT AIRDROP

import { ethers } from 'hardhat'
import { expect } from 'chai'
import { MerkleTree } from 'merkletreejs'
import { keccak256, Address } from 'ethers/utils'
import MerkleAirdrop from '../contracts/MerkleAirdrop.sol'
import MockNft from '../contracts/mocks/MockNft.sol'

const BN = (number: number) => ethers.BigNumber.from(number)

let merkleRoot: Buffer

let merkleAirdrop: MerkleAirdrop
let merkleTree: MerkleTree
let token: MockNft

let receiver: Address

let NUM_LEAVES: number

const elements: { account: string; tokenId: number }[] = []

function toLeaf(tokenId: any, account: any) {
    return Buffer.from(
        ethers.utils.solidityKeccak256(['uint256', 'address'], [tokenId, account]).slice(2),
        'hex'
    )
}

describe('MerkleAirdrop', function () {
    beforeEach(async () => {
        ;[receiver] = await ethers.getSigners()

        NUM_LEAVES = 1000
        for (let index = 0; index < NUM_LEAVES; index++) {
            const node = { tokenId: index, account: receiver.address }
            elements.push(node)
        }

        merkleTree = new MerkleTree(
            elements.map((token) => toLeaf(token.tokenId, token.account)),
            keccak256,
            { sortPairs: true }
        )

        merkleRoot = merkleTree.getRoot()

        token = await (
            await ethers.getContractFactory('MockNft')
        ).deploy("Ben's nft", 'BNFT', merkleTree.getHexRoot())

        await token.deployed()

        merkleAirdrop = await (
            await ethers.getContractFactory('MerkleAirdrop')
        ).deploy(token.address, merkleRoot)

        await merkleAirdrop.deployed()
    })
    it('should distribute tokens correctly', async function () {
        const account = receiver.address

        const root = merkleTree.getRoot()
        const rootFromContract = await merkleAirdrop.merkleRoot()

        // Convert the bytes32 value to a Buffer
        const paddedValue = ethers.utils.hexZeroPad(rootFromContract, 32)
        const bufferValue = Buffer.from(paddedValue.slice(2), 'hex')
        expect(root).to.deep.equal(bufferValue)

        const receiverBalance = await token.balanceOf(account)
        expect(receiverBalance).to.eql(BN(0))

        for (const token of elements) {
            //get leaf
            const leaf = toLeaf(token.tokenId, token.account)
            //get proof for leaf
            const proof = merkleTree.getHexProof(leaf)
            //verify proof is correct
            const isVerified = merkleTree.verify(proof, leaf, root)
            expect(isVerified).to.be.true

            await merkleAirdrop.claim(token.tokenId, account, proof)
        }
        const receiverBalanceAfter = await token.balanceOf(account)
        expect(receiverBalanceAfter).to.eql(BN(1000))
    })
    it('should fail if the merkle proof is invalid', async function () {
        const recipient = receiver.address
        const index = 0

        const leaf = ethers.utils.keccak256(
            ethers.utils.defaultAbiCoder.encode(['uint256', 'address'], [index, recipient])
        )
        const invalidProof = new MerkleTree([leaf], 1).getHexProof(leaf)

        await expect(merkleAirdrop.claim(index, recipient, invalidProof)).to.be.revertedWith(
            'InvalidProof'
        )
    })
    it('should revert if attempted to mint again', async function () {
        //get leaf
        const leaf = toLeaf(0, receiver.address)
        //get proof for leaf
        const proof = merkleTree.getHexProof(leaf)
        await merkleAirdrop.claim(0, receiver.address, proof)
        await expect(merkleAirdrop.claim(0, receiver.address, proof)).to.be.revertedWith(
            'AlreadyClaimed'
        )
    })
})
