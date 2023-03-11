//FOR NFT AIRDROP

import { ethers } from "hardhat";
import { expect } from "chai";
import { BigNumber, BigNumberish, constants } from "ethers";
import { keccak256, defaultAbiCoder } from "ethers/lib/utils";
import { MerkleTree } from "merkletreejs";
import {tokens} from './utils/tokens.json'
import MerkleAirdrop from '../contracts/MerkleAirdrop.sol';

const overrides = {
  gasLimit: 9999999,
};

const merkleRoot =
  "0x992a599fd84f199d7a3ca10559ebcc9d638fd74a200c28a5fc5fcafc8798d8a1";

let merkleAirdrop: MerkleAirdrop;
let token: any;
let accounts: any[];

beforeEach(async () => {
  const [owner, addr1, addr2] = await ethers.getSigners();


let merkleTree;
    merkleTree = new MerkleTree(Object.entries(tokens)); //not finished!

  merkleAirdrop = await (
    await ethers.getContractFactory("MerkleAirdrop")
  ).deploy(token.address, merkleRoot);
  await merkleAirdrop.deployed();
});

describe("MerkleAirdrop", function () {
  it("should fail if the merkle proof is invalid", async function () {
    const recipient = accounts[0].address;
    const index = 0;
    const amount = BigNumber.from("100");

    const leaf = keccak256(
      defaultAbiCoder.encode(["uint256", "address", "uint256"], [index, recipient, amount])
    );
    const invalidProof = new MerkleTree([leaf], 1).getHexProof(leaf);

    await expect(
      merkleAirdrop.claim(index, recipient, amount, invalidProof)
    ).to.be.revertedWith("Invalid proof");
  });

  it("should fail if the index has already been claimed", async function () {
    const recipient = accounts[0].address;
    const index = 0;
    const amount = BigNumber.from("100");

    const leaf = keccak256(
      defaultAbiCoder.encode(["uint256", "address", "uint256"], [index, recipient, amount])
    );
    const proof = new MerkleTree([leaf], 1).getHexProof(leaf);

    await merkleAirdrop.claim(index, recipient, amount, proof);

    await expect(
      merkleAirdrop.claim(index, recipient, amount, proof)
    ).to.be.revertedWith("MerkleAirdrop: Drop already claimed");
  });

  it("should distribute tokens correctly", async function () {
    const recipient = accounts[0].address;
    const index = 0;
    const amount = BigNumber.from("100");

    const leaf = keccak256(
      defaultAbiCoder.encode(["uint256", "address", "uint256"], [index, recipient, amount])
    );
    const proof = new MerkleTree([leaf], 1).getHexProof(leaf);

    await merkleAirdrop.claim(index, recipient, amount, proof);

    const balance = await token.balanceOf(recipient);
    expect(balance).to.eq(amount);
  });
});
