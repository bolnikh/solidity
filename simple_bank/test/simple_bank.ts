import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.connect();

describe("Simple Bank", function () {
  it("Start balance must be zero", async function () {
    const simple_bank = await ethers.deployContract("SimpleBank");

    expect(await simple_bank.getBalance()).to.equal(0);
  });


  it("Should emit the Deposited event when calling the deposit() function", async function () {
    const [owner] = await ethers.getSigners();
    const simple_bank = await ethers.deployContract("SimpleBank");
    const amount = 1000;

    await expect(simple_bank.deposit({ value: amount })).to.emit(simple_bank, "Deposited").withArgs(owner, amount);
  });

  it("Should balance must be growing when calling the deposit() function", async function () {
    const [owner] = await ethers.getSigners();
    const simple_bank = await ethers.deployContract("SimpleBank");
    const amount = 1000;

    await simple_bank.deposit({ value: amount });
    expect(await simple_bank.getBalance()).to.equal(amount);
  });

  it("Should emit the Withdrawn event when calling the withdraw() function", async function () {
    const [owner] = await ethers.getSigners();
    const simple_bank = await ethers.deployContract("SimpleBank");
    const amount = 1000;

    await simple_bank.deposit({ value: amount });

    await expect(simple_bank.withdraw(amount)).to.emit(simple_bank, "Withdrawn").withArgs(owner, amount);
  });

  it("Should balance must be zero after deposit() and withdraw() functions", async function () {
    const [owner] = await ethers.getSigners();
    const simple_bank = await ethers.deployContract("SimpleBank");
    const amount = 1000;

    await simple_bank.deposit({ value: amount });
    await simple_bank.withdraw(amount);
    expect(await simple_bank.getBalance()).to.equal(0);
  });


  it("Should balance grows after multiple deposit() function", async function () {
    const [owner] = await ethers.getSigners();
    const simple_bank = await ethers.deployContract("SimpleBank");
    const amount = 1000;

    await simple_bank.deposit({ value: amount });
    expect(await simple_bank.getBalance()).to.equal(amount);

    await simple_bank.deposit({ value: amount });
    expect(await simple_bank.getBalance()).to.equal(2 * amount);    
  });


  it("Can not withdraw() more than has on balance", async function () {
    const [owner] = await ethers.getSigners();
    const simple_bank = await ethers.deployContract("SimpleBank");
    const amount = 1000;

    await simple_bank.deposit({ value: amount });

    await expect(
      simple_bank.withdraw(2 * amount)
    ).to.be.revertedWith("Not enough balance");
  });



  it("Two user balances check", async function () {
    const [owner, user2] = await ethers.getSigners();
    const simple_bank = await ethers.deployContract("SimpleBank");
    const amount = 1000;

    await simple_bank.connect(owner).deposit({ value: amount });
    expect(await simple_bank.connect(owner).getBalance()).to.equal(amount);

    await simple_bank.connect(user2).deposit({ value: amount });
    expect(await simple_bank.connect(user2).getBalance()).to.equal(amount);

    await simple_bank.connect(owner).withdraw(amount);
    expect(await simple_bank.connect(owner).getBalance()).to.equal(0);

    await simple_bank.connect(user2).withdraw(amount);
    expect(await simple_bank.connect(user2).getBalance()).to.equal(0);    
  });

  /*
  it("The sum of the Increment events should match the current value", async function () {
    const counter = await ethers.deployContract("Counter");
    const deploymentBlockNumber = await ethers.provider.getBlockNumber();

    // run a series of increments
    for (let i = 1; i <= 10; i++) {
      await counter.incBy(i);
    }

    const events = await counter.queryFilter(
      counter.filters.Increment(),
      deploymentBlockNumber,
      "latest",
    );

    // check that the aggregated events match the current value
    let total = 0n;
    for (const event of events) {
      total += event.args.by;
    }

    expect(await counter.x()).to.equal(total);
  });
  */
});
