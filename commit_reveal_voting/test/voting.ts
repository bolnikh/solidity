import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.connect();

let voting;

let num_of_option = 3;
let commit_start;
let commit_end;
let reveal_start;
let reveal_end;

let user1;
let user2;
let user3;
let user4;
let user5;

let snapshotId;

let b  = "0x5b07e077a81ffc6b47435f65a8727bcc542bc6fc0f25a56210efb1a74b88a5ae";
let b0 = "0x0000000000000000000000000000000000000000000000000000000000000000";

describe("Voting", function () {
    beforeEach(async function () {
    
    snapshotId = await ethers.provider.send("evm_snapshot", []);

    commit_start = Math.floor(Date.now() / 1000) + 10;
    commit_end = Math.floor(Date.now() / 1000) + 60; 
    reveal_start = Math.floor(Date.now() / 1000) + 100;
    reveal_end = Math.floor(Date.now() / 1000) + 200;

    [user1, user2, user3, user4, user5] = await ethers.getSigners();
    
    let voting_factory = await ethers.getContractFactory("Voting", user1);

    voting = await voting_factory.deploy(num_of_option, commit_start, commit_end, reveal_start, reveal_end);
    await voting.waitForDeployment();

  });

  afterEach(async function () {
    await ethers.provider.send("evm_revert", [snapshotId]);
  });

  it("test_InitialValue", async function () {
    expect(await voting.num_of_options()).to.equal(num_of_option);
    expect(await voting.commit_start()).to.equal(commit_start);
    expect(await voting.commit_end()).to.equal(commit_end);
    expect(await voting.reveal_start()).to.equal(reveal_start);
    expect(await voting.reveal_end()).to.equal(reveal_end);

    let res = await voting.getResult();
    for (let i; i < res.length; i++) {
      expect(res[i]).to.equal(0);
    }    
  });


  it("test_commitTime", async function () {

    await expect(
      voting.connect(user2).commit(b)
    ).to.be.revertedWith("Commit is not in progress"); 

    await ethers.provider.send("evm_increaseTime", [11]);

    await expect(
      voting.connect(user2).commit(b0)
    ).to.be.revertedWith("Empty committed"); 

    voting.connect(user2).commit(b);

    await ethers.provider.send("evm_increaseTime", [100]);

    await expect(
      voting.connect(user2).commit(b)
    ).to.be.revertedWith("Commit is not in progress");     
  });    

  it("test_revealTime", async function () {
    await expect(
      voting.connect(user2).reveal(0,0)
    ).to.be.revertedWith("Reveal is not in progress"); 

    await ethers.provider.send("evm_increaseTime", [101]);

    await expect(
      voting.connect(user2).reveal(0,0)
    ).to.be.revertedWith("Invalid commit"); 

    await ethers.provider.send("evm_increaseTime", [101]);

    await expect(
      voting.connect(user2).reveal(0,0)
    ).to.be.revertedWith("Reveal is not in progress"); 
  }); 
  
  it("test_commitReveal", async function () {
    await ethers.provider.send("evm_increaseTime", [11]);

    let com1 = await voting.createCommitment(1, 100);
    await voting.commit(com1);

    await ethers.provider.send("evm_increaseTime", [101]);

    await voting.reveal(1, 100);

    let res = await voting.getResult();

    expect(res[1]).to.equal(1);
  }); 
  
  it("test_alreadyCommited", async function () {
    await ethers.provider.send("evm_increaseTime", [11]);

    let com1 = await voting.createCommitment(1, 100);

    await voting.commit(com1);
    
    await expect(
      voting.commit(com1)
    ).to.be.revertedWith("Already committed");

  }); 
  
  it("test_emptyCommited", async function () {
    await ethers.provider.send("evm_increaseTime", [11]);

    await expect(
      voting.commit(b0)
    ).to.be.revertedWith("Empty committed");

  }); 
  
  it("test_vote", async function () {
    await ethers.provider.send("evm_increaseTime", [11]);

    let com1 = await voting.createCommitment(1, 100);
    await voting.connect(user1).commit(com1);

    
    let com2 = await voting.createCommitment(1, 1000);
    await voting.connect(user2).commit(com2);  


    let com3 = await voting.createCommitment(2, 10000);
    await voting.connect(user3).commit(com3);

    let com4 = await voting.createCommitment(0, 1000); 
    await voting.connect(user4).commit(com4);

    await ethers.provider.send("evm_increaseTime", [101]);
    
    await voting.connect(user1).reveal(1, 100);

    await voting.connect(user2).reveal(1, 1000);

    await voting.connect(user3).reveal(2, 10000);

    await voting.connect(user4).reveal(0, 1000);

    let res = await voting.getResult();

    expect(res[0]).to.equal(1);
    expect(res[1]).to.equal(2);
    expect(res[2]).to.equal(1);
   
  }); 
  
  
});