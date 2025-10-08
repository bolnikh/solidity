// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {SimpleBank} from "./SimpleBank.sol";
import {Test} from "forge-std/Test.sol";
import "hardhat/console.sol";

contract SimpleBankTest is Test {
  SimpleBank simple_bank;
  uint amount = 10000;

  receive() external payable {}

  function setUp() public {
    simple_bank = new SimpleBank();
  }

  function test_InitialValue() public view {
    require(simple_bank.getBalance() == 0, "Initial value should be 0");
  }

  function test_UseBank() public {

    simple_bank.deposit{value: amount}();

    require(simple_bank.getBalance() == amount, "Must be right balance 1");

    simple_bank.deposit{value: amount}();

    require(simple_bank.getBalance() == 2 * amount, "Must be right balance 2");

    simple_bank.withdraw(amount);

    require(simple_bank.getBalance() == amount, "Must be right balance 1 - 1");

    vm.expectRevert();
    simple_bank.withdraw(2* amount);
  }



}
