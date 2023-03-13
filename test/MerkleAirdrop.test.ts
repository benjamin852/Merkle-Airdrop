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

const merkleRoot = '0x992a599fd84f199d7a3ca10559ebcc9d638fd74a200c28a5fc5fcafc8798d8a1'

let merkleAirdrop: MerkleAirdrop
let merkleTree: MerkleTree
let token: MockNft
let accounts: any[]

let owner: Address
let receiver: Address

let NUM_LEAVES: number
let NUM_SAMPLES: number

const elements: { account: string; tokenId: number }[] = []

function toNode(tokenId: any, account: any) {
    return Buffer.from(
        ethers.utils.solidityKeccak256(['uint256', 'address'], [tokenId, account]).slice(2),
        'hex'
    )
}

beforeEach(async () => {
    ;[owner, receiver] = await ethers.getSigners()

    NUM_LEAVES = 10_000
    NUM_SAMPLES = 25
    for (let index = 0; index < NUM_LEAVES; index++) {
        const node = { tokenId: index, account: receiver.address }
        elements.push(node)
    }

    merkleTree = new MerkleTree(
        elements.map((token) => toNode(token.account, token.tokenId)),
        keccak256,
        { sortPairs: true }
    )

    token = await (
        await ethers.getContractFactory('MockNft')
    ).deploy("Ben's nft", 'BNFT', merkleTree.getHexRoot())

    await token.deployed()

    merkleAirdrop = await (
        await ethers.getContractFactory('MerkleAirdrop')
    ).deploy(token.address, merkleRoot)

    await merkleAirdrop.deployed()
})

describe('MerkleAirdrop', function () {
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
            ethers.utils.defaultAbiCoder.encode(
                ['uint256', 'address', 'uint256'],
                [index, recipient, amount]
            )
        )
        const proof = new MerkleTree([leaf], 1).getHexProof(leaf)

        await merkleAirdrop.claim(index, recipient, amount, proof)

        await expect(merkleAirdrop.claim(index, recipient, amount, proof)).to.be.revertedWith(
            'MerkleAirdrop: Drop already claimed'
        )
    })

    it('should distribute tokens correctly', async function () {
        const account = receiver.address
        const amount = BigNumber.from('10000')

        const root = merkleTree.getRoot()

        for (const [tokenId, account] of Object.entries(elements)) {
            /**
             * Create merkle proof (anyone with knowledge of the merkle tree)
             */
            const proof = this.merkleTree.getHexProof(toNode(tokenId, account))
            console.log(proof, 'proof')
        }

        const leaf = ethers.utils.keccak256(
            ethers.utils.defaultAbiCoder.encode(['uint256', 'address'], [index, recipient])
        )
        const proof = new MerkleTree([leaf], 1).getHexProof(leaf)

        await merkleAirdrop.claim(index, recipient, amount, proof)

        // const balance = await token.balanceOf(recipient)
        // expect(balance).to.eq(amount)
    })
})
