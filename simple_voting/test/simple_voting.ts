import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.connect();

let simple_voting;

let num_of_option = 3;
let startTime;
let endTime; 

let user1;
let user2;
let user3;
let user4;
let user5;

let snapshotId;

describe("SimpleVoting", function () {
    beforeEach(async function () {
    
    snapshotId = await ethers.provider.send("evm_snapshot", []);

    startTime = Math.floor(Date.now() / 1000) + 10;
    endTime = startTime + 60; 

    [user1, user2, user3, user4, user5] = await ethers.getSigners();
    
    let simple_voting_factory = await ethers.getContractFactory("SimpleVoting", user1);

    simple_voting = await simple_voting_factory.deploy(num_of_option, startTime, endTime);
    await simple_voting.waitForDeployment();

  });

  afterEach(async function () {
    // revert to snapshot
    await ethers.provider.send("evm_revert", [snapshotId]);
  });

  it("test_InitialValue", async function () {
    expect(await simple_voting.num_of_options()).to.equal(num_of_option);
    expect(await simple_voting.vote_start()).to.equal(startTime);
    expect(await simple_voting.vote_end()).to.equal(endTime);
  });

  it("test_voteTime", async function () {
    await expect(
      simple_voting.connect(user1).vote(0)
    ).to.be.revertedWith("Vote is not in progress");

    await ethers.provider.send("evm_increaseTime", [11]);
    simple_voting.connect(user1).vote(0);

    await ethers.provider.send("evm_increaseTime", [100]);
    await expect(
      simple_voting.connect(user2).vote(0)
    ).to.be.revertedWith("Vote is not in progress");    
  });

  it("test_ZeroAddress", async function () {
    await ethers.provider.send("evm_increaseTime", [11]);

    await expect(
      simple_voting.delegate(ethers.ZeroAddress)
    ).to.be.revertedWith("Empty address not allowed");  
  });

  it("test_goodOption", async function () {
    await ethers.provider.send("evm_increaseTime", [11]);

    await expect(
      simple_voting.connect(user2).vote(num_of_option)
    ).to.be.revertedWith("Wrong num");  
  });

  it("test_vote", async function () {
    await ethers.provider.send("evm_increaseTime", [11]);

    let op = 0;
    let op1 = 1;
    await simple_voting.connect(user4).vote(op);

    let res = await simple_voting.connect(user4).getResult();
    expect(res[op]).to.equal(1);

    await expect(
      simple_voting.connect(user4).vote(op)
    ).to.be.revertedWith("Already vote"); 


    await simple_voting.connect(user1).vote(op);
    await simple_voting.connect(user2).vote(op);

    res = await simple_voting.connect(user1).getResult();
    expect(res[op]).to.equal(3);

    await simple_voting.connect(user3).vote(op1);

    res = await simple_voting.connect(user3).getResult();
    expect(res[op1]).to.equal(1);
  });

  it("test_delegate", async function () {
    await ethers.provider.send("evm_increaseTime", [11]);

    let op = 0;

    await simple_voting.connect(user1).delegate(user2);

    await expect(
      simple_voting.connect(user3).delegateVote(user1, op)
    ).to.be.revertedWith("Not delegated");

    await simple_voting.connect(user2).delegateVote(user1, op);

    await simple_voting.connect(user4).delegate(user2);

    await simple_voting.connect(user2).delegateVote(user4, op);

    let res = await simple_voting.connect(user4).getResult();

    expect(res[op]).to.equal(2);
  });


});