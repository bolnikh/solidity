import { expect } from "chai";
import { network } from "hardhat";
import { SignBill } from "../types/ethers-contracts/SignBill.js";
import { Signer } from 'ethers';

const { ethers } = await network.connect();

let sign_bill : SignBill;

let user1 : Signer ;
let user2 : Signer ;
let user3 : Signer ;
let user4 : Signer ;
let user5 : Signer ;

let snapshotId : number;


describe("SignBill", function () 
{
    beforeEach(async function () 
    {
        snapshotId = await ethers.provider.send("evm_snapshot", []);

        [user1, user2, user3, user4, user5] = await ethers.getSigners();
        
        let factory = await ethers.getContractFactory("SignBill", user1);

        sign_bill = await factory.deploy({value: ethers.parseEther("100")});
        await sign_bill.waitForDeployment();
    });

    afterEach(async function () 
    {
        await ethers.provider.send("evm_revert", [snapshotId]);
    });

    it("test_InitialValue", async function () 
    {
        expect(await sign_bill.owner()).to.equal(user1);
        expect(await ethers.provider.getBalance(sign_bill)).to.equal(ethers.parseEther("100"));
    });

    it("test_Bill", async function () 
    {
        const amount = ethers.parseUnits("1", "ether");
        const bill_num = 1;

        const hash = ethers.solidityPackedKeccak256(
            ["address", "uint256", "uint256", "address"],
            [await user2.getAddress(), amount, bill_num, await sign_bill.getAddress()]
        );

        const messageHashBin = ethers.getBytes(hash);

        const signature = await user1.signMessage(messageHashBin);

        await expect(
            sign_bill.connect(user2).pay_bill(bill_num + 1, amount, signature)
        ).to.be.revertedWith("invalid signature!"); 

        await expect(
            sign_bill.connect(user2).pay_bill(bill_num, amount + 1n, signature)
        ).to.be.revertedWith("invalid signature!"); 

        await expect(
            sign_bill.connect(user3).pay_bill(bill_num, amount, signature)
        ).to.be.revertedWith("invalid signature!"); 

        const tx = await sign_bill.connect(user2).pay_bill(bill_num, amount, signature);
        await tx.wait();

        expect(tx).to.changeEtherBalance(ethers, user2, amount);


        await expect(
            sign_bill.connect(user2).pay_bill(bill_num, amount, signature)
        ).to.be.revertedWith("bill already payed");

    });

    it("test_bill_2", async function(){

        const amount1 = ethers.parseUnits("1", "ether");
        const bill_num1 = 1;

        const hash1 = ethers.solidityPackedKeccak256(
            ["address", "uint256", "uint256", "address"],
            [await user2.getAddress(), amount1, bill_num1, await sign_bill.getAddress()]
        );

        const messageHashBin1 = ethers.getBytes(hash1);

        const signature1 = await user1.signMessage(messageHashBin1);

        const amount2 = ethers.parseUnits("2", "ether");
        const bill_num2 = 2;

        const hash2 = ethers.solidityPackedKeccak256(
            ["address", "uint256", "uint256", "address"],
            [await user3.getAddress(), amount2, bill_num2, await sign_bill.getAddress()]
        );

        const messageHashBin2 = ethers.getBytes(hash2);

        const signature2 = await user1.signMessage(messageHashBin2);


        const tx1 = await sign_bill.connect(user2).pay_bill(bill_num1, amount1, signature1);
        await tx1.wait();

        expect(tx1).to.changeEtherBalance(ethers, user2, amount1);


        const tx2 = await sign_bill.connect(user3).pay_bill(bill_num2, amount2, signature2);
        await tx2.wait();

        expect(tx2).to.changeEtherBalance(ethers, user3, amount2);

    });


});