//FOR NFT AIRDROP

import { ethers } from 'hardhat'
import { expect } from 'chai'
// import { keccak256, defaultAbiCoder } from "ethers/lib/utils";
import { MerkleTree } from 'merkletreejs'
import tokens from './utils/tokens.json'
import MerkleAirdrop from '../contracts/MerkleAirdrop.sol'
import MockNft from '../contracts/mocks/MockNft.sol'
import { BigNumber } from 'ethers'
import { keccak256 } from 'ethers/lib/utils'
import { Address } from 'ethers/utils'

const overrides = {
    gasLimit: 9999999,
}

let merkleRoot: Buffer

let merkleAirdrop: MerkleAirdrop
let merkleTree: MerkleTree
let token: MockNft
let accounts: any[]

let owner: Address
let receiver: Address

let NUM_LEAVES: number
let NUM_SAMPLES: number

const elements: { account: string; tokenId: number }[] = []

function toLeaf(tokenId: any, account: any) {
    return Buffer.from(
        ethers.utils.solidityKeccak256(['uint256', 'address'], [tokenId, account]).slice(2),
        'hex'
    )
}

describe('MerkleAirdrop', function () {
    beforeEach(async () => {
        ;[owner, receiver] = await ethers.getSigners()

        NUM_LEAVES = 1000
        NUM_SAMPLES = 25
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
    /*
    it('should fail if the merkle proof is invalid', async function () {
        const recipient = receiver.address
        const index = 0
        // const tokenId = BigNumber.from('100')

        const leaf = ethers.utils.keccak256(
            ethers.utils.defaultAbiCoder.encode(['uint256', 'address'], [index, recipient])
        )
        const invalidProof = new MerkleTree([leaf], 1).getHexProof(leaf)

        await expect(merkleAirdrop.claim(index, recipient, invalidProof)).to.be.revertedWith(
            'Invalid proof'
        )
    })

    it('should fail if the index has already been claimed', async function () {
        const recipient = accounts[0].address
        const index = 0
        const amount = BigNumber.from('100')

        const leaf = ethers.utils.keccak256(
            ethers.utils.defaultAbiCoder.encode(['uint256', 'address'], [index, recipient])
        )
        const proof = new MerkleTree([leaf], 1).getHexProof(leaf)

        await merkleAirdrop.claim(index, recipient, amount, proof)

        await expect(merkleAirdrop.claim(index, recipient, amount, proof)).to.be.revertedWith(
            'MerkleAirdrop: Drop already claimed'
        )
    })
*/
    it('should distribute tokens correctly', async function () {
        const account = receiver.address
        const amount = BigNumber.from('1000')

        const root = merkleTree.getRoot()
        const rootFromContract = await merkleAirdrop.merkleRoot()

        // Convert the bytes32 value to a Buffer
        const paddedValue = ethers.utils.hexZeroPad(rootFromContract, 32)
        const bufferValue = Buffer.from(paddedValue.substr(2), 'hex')
        expect(root).to.deep.equal(bufferValue)

        const receiverBalance = await token.balanceOf(account)
        console.log(receiverBalance.toString(), 'the receiver balance')

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
        console.log(receiverBalanceAfter.toString(), 'the receiver balance')

        // const balance = await token.balanceOf(recipient)
        // expect(balance).to.eq(amount)
    })
})
