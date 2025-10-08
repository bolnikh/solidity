import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.connect();

let mft;
let admin;
let user1;
let user2;
let user3;
let user4;


describe("Myfirst token", function () {
  beforeEach(async function () {
    // Получаем аккаунты
    [admin, user1, user2, user3, user4] = await ethers.getSigners();
    
    // Деплоим контракт
    let fac = await ethers.getContractFactory("MyFirstToken");
    mft = await fac.deploy("My First Token", "MFT", 18, admin);
    await mft.waitForDeployment();
  });

    it("Should set the correct token name and symbol", async function () {
      expect(await mft.name()).to.equal("My First Token");
      expect(await mft.symbol()).to.equal("MFT");
    })

  it("Start balance must be zero", async function () {
    expect(await mft.balanceOf(admin)).to.equal(0);
  });


  it("Admin can mint", async function() {
    let val = 1000000000000000000n;
    await mft.adminMint(admin, val);
    expect(await mft.balanceOf(admin)).to.equal(val);
  });

  it("Admin mint and burn", async function() {
    let val = ethers.parseEther("0.1");
    let little_val = 100000n;

    await mft.adminMint(admin, val);
    expect(await mft.balanceOf(admin)).to.equal(val);

    await mft.adminBurn(admin, val);
    expect(await mft.balanceOf(admin)).to.equal(0);

    await mft.adminMint(admin, val);
    await mft.adminBurn(admin, val - little_val);
    expect(await mft.balanceOf(admin)).to.equal(little_val);

    await expect(
        mft.adminBurn(admin, little_val + little_val)
    ).to.be.revertedWith("Not enought balance");

    await mft.adminBurn(admin, little_val);
    expect(await mft.balanceOf(admin)).to.equal(0);
  });



   it("Erc 20 func", async function() {
        let val = ethers.parseEther("1");
        await mft.adminMint(user1, val);

        expect(await mft.balanceOf(user1)).to.equal(val);
        expect(await mft.totalSupply()).to.equal(val);

        let val1 = ethers.parseEther("0.1");
        await mft.connect(user1).transfer(user2, val1);
      
        expect(await mft.balanceOf(user2)).to.equal(val1);
        expect(await mft.balanceOf(user1)).to.equal(val - val1);
        expect(await mft.totalSupply()).to.equal(val);
   });



    it("erc 20 approve", async function() {
        let val = ethers.parseEther("1");
        await mft.adminMint(user1, val);

        let val1 = ethers.parseEther("0.1");
        await mft.connect(user1).approve(user2, val1);
        expect(await mft.allowance(user1, user2)).to.equal(val1);

        let val2 = ethers.parseEther("0.01");
        await mft.connect(user2).transferFrom(user1, user3, val2);

        expect(await mft.balanceOf(user1)).to.equal(val - val2);
        expect(await mft.balanceOf(user3)).to.equal(val2);
        expect(await mft.allowance(user1, user2)).to.equal(val1 - val2);

        await expect(
            mft.connect(user2).transferFrom(user1, user3, val)
        ).to.be.revertedWith("Allowance must be enought");
    });




   it("Test event Transfer", async function() {
        let val = ethers.parseEther("1");
        await mft.adminMint(user1, val);

        let val1 = ethers.parseEther("0.1"); 

        await expect(mft.connect(user1).transfer(user2, val1))
        .to.emit(mft, "Transfer")
        .withArgs(user1, user2, val1);

   });



   it("test event Approval", async function() {
        let val = ethers.parseEther("1");
        await mft.adminMint(user1, val);

        let val1 = ethers.parseEther("0.1"); 

        await expect(mft.connect(user1).approve(user2, val1))
        .to.emit(mft, "Approval")
        .withArgs(user1, user2, val1);
   });




//   it("", async function() {});

/*
    await expect(myToken.approve(addr1.address, 1000))
      .to.emit(myToken, "Approval")
      .withArgs(owner.address, addr1.address, 1000);

    // Для кастомных ошибок
    await expect(
      myToken.someFunctionThatReverts()
    ).to.be.revertedWithCustomError(myToken, "CustomErrorName");
    
    
    // Проверка revert
expect(transaction).to.be.reverted;
expect(transaction).to.be.revertedWith("Error message");
expect(transaction).to.be.revertedWithCustomError(contract, "ErrorName");

// Проверка событий
expect(transaction).to.emit(contract, "EventName").withArgs(arg1, arg2);

// Проверка изменения баланса
await expect(transaction).to.changeEtherBalance(account, value);
await expect(transaction).to.changeTokenBalance(token, account, value);

// Проверка равенства
expect(value).to.equal(100);
expect(value).to.be.gt(50); // greater than
expect(value).to.be.lt(200); // less than


*/


});