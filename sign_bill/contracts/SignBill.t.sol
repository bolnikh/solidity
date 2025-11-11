// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {SignBill} from "./SignBill.sol";
import {Test} from "forge-std/Test.sol";

contract SignBillTest is Test 
{
    SignBill sign_bill;

    uint init_balance = 100 ether;

    address constant USER1 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address constant USER2 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
    address constant USER3 = 0x90F79bf6EB2c4f870365E785982E1f101E93b906;
    address constant USER4 = 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65;

    uint constant USER1_PKEY = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;


    function setUp() public {
        vm.deal(USER1, 1000 ether);

        vm.prank(USER1);
        sign_bill = new SignBill{value: init_balance}();
    }

    function test_InitialValue() public view
    {
        require(sign_bill.owner() == USER1, "Wrong owner");
        require(address(sign_bill).balance == init_balance, "Wrong init balance");
    }


    function testBill() public 
    {
        address to = USER2;
        uint amount = 1 ether;
        uint bill_num = 1;

        bytes32 message_hash = sign_bill.createMessage(to, amount, bill_num);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(USER1_PKEY, message_hash);
        bytes memory signature = abi.encodePacked(r, s, v);

        uint256 initialContractBalance = address(USER2).balance;

        vm.prank(USER2);
        sign_bill.pay_bill(bill_num, amount, signature);

        assertEq(address(USER2).balance, initialContractBalance + 1 ether, "USER2 balance should increase");

        vm.expectRevert("bill already payed");
        vm.prank(USER2);
        sign_bill.pay_bill(bill_num, amount, signature);

        // ------


        to = USER3;
        amount = 3 ether;
        bill_num = 2;

        bytes32 message_hash_3 = sign_bill.createMessage(to, amount, bill_num);

        (v, r, s) = vm.sign(USER1_PKEY, message_hash_3);
        bytes memory signature_3 = abi.encodePacked(r, s, v);

        initialContractBalance = address(USER3).balance;

        vm.prank(USER3);
        sign_bill.pay_bill(bill_num, amount, signature_3);

        assertEq(address(USER3).balance, initialContractBalance + 3 ether, "USER3 balance should increase");

        vm.expectRevert("bill already payed");
        vm.prank(USER3);
        sign_bill.pay_bill(bill_num, amount, signature_3);

    }


}