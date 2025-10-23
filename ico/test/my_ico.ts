import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.connect();

let mico;
let owner;
let user1;
let user2;
let user3;
let user4;

let mt;

const price = BigInt(0.001 * 1.e18);
const soft_cap = BigInt(0.1 * 1.e18);   
const hard_cap = BigInt(1.e18); 
const startTime = Math.floor(Date.now() / 1000) + 10;
const endTime = startTime + 3600; 

let snapshotId;


describe("ICO", function () {
    beforeEach(async function () {

    snapshotId = await ethers.provider.send("evm_snapshot", []);

    // get accounts
    [owner, user1, user2, user3, user4] = await ethers.getSigners();
    
    let my_ico_fac = await ethers.getContractFactory("MyICO", owner);

    mico = await my_ico_fac.deploy(price, soft_cap, hard_cap, startTime, endTime);
    await mico.waitForDeployment();


    const tx = await mico.deployToken("My Token", "MT");
    await tx.wait();

    const tokenAddress = await mico.getToken();

    let abi =[
                "function balanceOf(address) view returns (uint256)",

                "function name() view returns (string)",
                "function symbol() view returns (string)",
                "function owner() view returns (address)",

    ];
    mt = new ethers.Contract(tokenAddress, abi, ethers.provider);

  });

  afterEach(async function () {
    // revert to snapshot
    await ethers.provider.send("evm_revert", [snapshotId]);
  });


  it("Initial value", async function () {
    expect(await mt.owner()).to.equal(await mico.getAddress());

    expect(await mt.name()).to.equal("My Token");
    expect(await mt.symbol()).to.equal("MT");
  });

  it("mint", async function () {

    expect(await mt.balanceOf(user1)).to.equal(0n);

    // do not work
    // let val = 10000n;

    // const mico_address = await mico.getAddress();
    // const mtAsMICO = mt.connect(await ethers.getSigner(mico_address));
    // await mtAsMICO.mint(user1, val);

    // expect(await mt.balanceOf(user1)).to.equal(val);

  });  

  it("test_ICO_start_buy", async function () {
    let val = ethers.parseEther("0.1");

    await expect(
      mico.connect(user1).buyTokens({value: val})
    ).to.be.revertedWith("ICO not started");

    
    await ethers.provider.send("evm_increaseTime", [60]);


    expect(await mt.balanceOf(user1)).to.equal(0n);
    await mico.connect(user1).buyTokens({value: val});
    expect(await mt.balanceOf(user1)).to.equal(BigInt(val / price));

    await mico.connect(user1).buyTokens({value: val});
    expect(await mt.balanceOf(user1)).to.equal(BigInt(2n * val / price));

    await expect(
      mico.connect(user1).buyTokens({value: price - 1n})
    ).to.be.revertedWith("Send enough ether to join");
  });


  it("test_ICO_stop_time", async function () {
    let val = ethers.parseEther("0.1");
    await ethers.provider.send("evm_increaseTime", [7200]);

    await expect(
      mico.connect(user1).buyTokens({value: val})
    ).to.be.revertedWith("ICO ended");
  });
  
  it("test_ICO_stop_funds", async function () {
    let val = ethers.parseEther("1.1");
    await ethers.provider.send("evm_increaseTime", [60]);

    await mico.connect(user1).buyTokens({value: val});

    await expect(
      mico.connect(user1).buyTokens({value: val})
    ).to.be.revertedWith("Funds is already enought");
  });

  it("test_withdraw", async function () {
    await ethers.provider.send("evm_increaseTime", [60]);
    let val = ethers.parseEther("1.1");

    await mico.connect(user1).buyTokens({value: val});

    await expect(
      mico.connect(user1).withdrawFunds()
    ).to.be.revertedWith("Only owner allowed");    

    await expect(
      mico.connect(owner).withdrawFunds()
    ).to.changeEtherBalance(ethers, owner, val);

  });

  it("test_getFundsBackOnICOFail_1", async function () {
    await ethers.provider.send("evm_increaseTime", [60]);
    let val = ethers.parseEther("0.01");

    await mico.connect(user1).buyTokens({value: val});

    await expect(
      mico.connect(user1).getFundsBackOnICOFail()
    ).to.be.revertedWith("ICO not ended"); 

    await ethers.provider.send("evm_increaseTime", [7200]);

    await expect(
      mico.connect(user1).getFundsBackOnICOFail()
    ).to.changeEtherBalance(ethers, user1, val);

  });

  it("test_getFundsBackOnICOFail_2", async function () {
    await ethers.provider.send("evm_increaseTime", [60]);
    let val = ethers.parseEther("0.01");

    await mico.connect(user1).buyTokens({value: val});

    await mico.connect(user1).buyTokens({value: val});

    await mico.connect(user2).buyTokens({value: val});

    await ethers.provider.send("evm_increaseTime", [7200]);

    await expect(
      mico.connect(user1).getFundsBackOnICOFail()
    ).to.changeEtherBalance(ethers, user1, 2n * val);    

    await expect(
      mico.connect(user2).getFundsBackOnICOFail()
    ).to.changeEtherBalance(ethers, user2, val);  

  }); 
  
  it("test_stop_after_withdraw", async function () {
    await ethers.provider.send("evm_increaseTime", [60]);
    let val = ethers.parseEther("1.1");

    await mico.connect(user1).buyTokens({value: val});

    await mico.connect(owner).withdrawFunds();

    //await ethers.provider.send("evm_mine", []);

    await expect(
      mico.connect(user1).buyTokens({value: val})
    ).to.be.revertedWith("ICO finished"); 

  });
});
