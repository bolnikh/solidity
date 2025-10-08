// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {MyFirstToken} from "./MyFirstToken.sol";
import {Test} from "forge-std/Test.sol";

// Solidity tests are compatible with foundry, so they
// use the same syntax and offer the same functionality.

contract MyFirstTokenTest is Test {
    MyFirstToken mft;

      // Определяем адреса как константы
    address constant ADMIN = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address constant USER1 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address constant USER2 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
    address constant USER3 = 0x90F79bf6EB2c4f870365E785982E1f101E93b906;
    address constant USER4 = 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function setUp() public 
    {
      vm.deal(ADMIN, 100 ether);
      vm.deal(USER1, 100 ether);
      vm.deal(USER2, 100 ether);
      vm.deal(USER3, 100 ether);
      vm.deal(USER4, 100 ether);

      mft = new MyFirstToken("My First Token", "MFT", 18, ADMIN);
    }

    function test_InitialValue() public view 
    {
      require(mft.balanceOf(ADMIN) == 0, "Initial value should be 0");
    }

    function test_admin() public 
    {
      vm.prank(ADMIN);

      uint val = 0.1 ether;
      mft.adminMint(ADMIN, val);
      require(mft.balanceOf(ADMIN) == val, "Value must be val");
    }

    function test_adminFunc() public 
    {
        vm.startPrank(ADMIN);

        uint val = 0.1 ether;
        mft.adminMint(ADMIN, val);
        require(mft.balanceOf(ADMIN) == val, "Value must be val");

        mft.adminBurn(ADMIN, val);
        require(mft.balanceOf(ADMIN) == 0, "value should be 0");

        mft.adminMint(ADMIN, val);
        uint little_val = 10000;
        mft.adminBurn(ADMIN, val - little_val);
        require(mft.balanceOf(ADMIN) == little_val, "value should be little_val");

        vm.expectRevert("Not enought balance");
        mft.adminBurn(ADMIN, 2*little_val);

        mft.adminBurn(ADMIN, little_val);
        require(mft.balanceOf(ADMIN) == 0, "value should be 0");
    }  


    function test_erc() public 
    {
        vm.prank(ADMIN);
        uint val = 1 ether;
        mft.adminMint(USER1, val);

        require(mft.balanceOf(USER1) == val, "Value must be val");
        require(mft.totalSupply() == val, "TotalSupply must be val");

        vm.prank(USER1);
        uint val1 = 0.1 ether;
        mft.transfer(USER2, val1);

        require(mft.balanceOf(USER2) == val1, "Value must be val1");
        require(mft.balanceOf(USER1) == val - val1, "Value must be val - val1");

        require(mft.totalSupply() == val, "TotalSupply must be val");
    }

    function test_erc_approve() public 
    {
        vm.prank(ADMIN);
        uint val = 1 ether;
        mft.adminMint(USER1, val);

        vm.prank(USER1);
        uint val1 = 0.1 ether;
        mft.approve(USER2, val1);

        require(mft.allowance(USER1, USER2) == val1, "Approve must be val1");

        vm.prank(USER2);

        uint val2 = 0.01 ether;
        mft.transferFrom(USER1, USER3, val2);

        require(mft.balanceOf(USER1) == val - val2, "Value must be val1");
        require(mft.balanceOf(USER3) == val2, "Value must be val1");
        require(mft.allowance(USER1, USER2) == val1 - val2, "Approve must be val1");

        vm.prank(USER2);
        vm.expectRevert("Allowance must be enought");
        mft.transferFrom(USER1, USER3, val);
    }

    function test_event_Transfer() public
    {
        vm.prank(ADMIN);
        uint val = 1 ether;
        mft.adminMint(USER1, val);

        uint val1 = 0.1 ether;
        vm.expectEmit(true, true, false, true);
        emit Transfer(USER1, USER2, val1);

        vm.prank(USER1);
        mft.transfer(USER2, val1);
    }

    function test_event_Approval() public
    {
        vm.prank(ADMIN);
        uint val = 1 ether;
        mft.adminMint(USER1, val);

        uint val1 = 0.1 ether;

        vm.expectEmit(true, true, false, true);
        emit Approval(USER1, USER2, val1);

        vm.prank(USER1);        
        mft.approve(USER2, val1);
    }    
}