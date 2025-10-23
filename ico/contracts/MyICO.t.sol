// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {MyICO} from "./MyICO.sol";
import {MyToken} from "./MyToken.sol";
import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";


contract MyICOTest is Test {

    MyICO mico;
    MyToken mt;

    uint256 startTime;
    uint256 endTime;

    uint256 price;
    uint256 soft_cap;
    uint256 hard_cap;

      // Определяем адреса как константы
    address constant ADMIN = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address constant USER1 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address constant USER2 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
    address constant USER3 = 0x90F79bf6EB2c4f870365E785982E1f101E93b906;
    address constant USER4 = 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65;

    error OwnableUnauthorizedAccount(address account);

    function setUp() public 
    {
        vm.deal(ADMIN, 100 ether);
        vm.deal(USER1, 100 ether);
        vm.deal(USER2, 100 ether);
        vm.deal(USER3, 100 ether);
        vm.deal(USER4, 100 ether);
        
        vm.startPrank(ADMIN);

        startTime = block.timestamp + 100;
        endTime = block.timestamp + 3700;

        price = 0.001 ether;
        soft_cap = 0.1 ether;
        hard_cap = 1 ether;

        mico = new MyICO(price, soft_cap, hard_cap, startTime, endTime);
        mt = mico.deployToken("My Token", "MT");

        vm.stopPrank();
    }

    function test_InitialValue() public view 
    {
      require(mt.owner() == address(mico), "MyToken owner must be admin");

      require(keccak256(abi.encodePacked(mt.name())) == keccak256(abi.encodePacked("My Token")), "Wrong token name");
      require(keccak256(abi.encodePacked(mt.symbol())) == keccak256(abi.encodePacked("MT")), "Wrong token symbol");
    }

    function test_Mint() public  
    {
      vm.prank(USER4);
      vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, USER4));
      mt.mint(USER1, 1);

      vm.startPrank(address(mico));

      require(mt.balanceOf(USER1) == 0, "MyToken balance must be zero");

      uint val = 1000;
      mt.mint(USER1, val);

      require(mt.balanceOf(USER1) == val, "MyToken mint failed");
      vm.stopPrank();
    }

    function test_ICO_start_buy() public
    {
      vm.startPrank(USER1);
      vm.expectRevert("ICO not started");
      mico.buyTokens{value: 1 ether}();

      vm.warp(startTime + 1);
      uint val = 0.1 ether;
      mico.buyTokens{value: val}();

      uint256 tokens = val / price;
      require(tokens == mt.balanceOf(USER1), "Wrong number of bought tokens");

      mico.buyTokens{value: val}();
      require(tokens * 2 == mt.balanceOf(USER1), "Wrong number of bought tokens 1");

      vm.expectRevert("Send enough ether to join");
      mico.buyTokens{value: price - 1}();

      vm.stopPrank();
    }

    function test_ICO_stop_time() public
    {
      vm.startPrank(USER1);
      vm.warp(endTime + 1);

      vm.expectRevert("ICO ended");
      mico.buyTokens{value: 1 ether}();
      vm.stopPrank();      
    }

    function test_ICO_stop_funds() public
    {
      vm.startPrank(USER1);
      vm.warp(startTime + 1);

      mico.buyTokens{value: 1.1 ether}();

      vm.expectRevert("Funds is already enought");
      mico.buyTokens{value: 0.1 ether}();

      //console.log(address(mico).balance);

      vm.stopPrank();      
    }


    function test_withdraw() public
    {
      vm.startPrank(USER1);
      vm.warp(startTime + 1);

      uint256 val = 1.1 ether;
      mico.buyTokens{value: val}();

      vm.expectRevert("Only owner allowed");
      mico.withdrawFunds();
      vm.stopPrank();

      vm.startPrank(ADMIN);
      uint256 balanceBefore = address(ADMIN).balance;
      mico.withdrawFunds();
      uint256 balanceAfter = address(ADMIN).balance;

      require(balanceAfter - balanceBefore == val, "All funds must be return");
      vm.stopPrank();
    }

    function test_getFundsBackOnICOFail_1() public
    {
      
      vm.startPrank(USER1);
      vm.warp(startTime + 1);

      uint256 val = 0.01 ether;
      mico.buyTokens{value: val}();

      vm.expectRevert("ICO not ended");
      mico.getFundsBackOnICOFail();

      vm.warp(endTime + 1);

      uint256 balanceBefore = address(USER1).balance;
      mico.getFundsBackOnICOFail();
      uint256 balanceAfter = address(USER1).balance;

      require(balanceAfter - balanceBefore == val, "All funds must be return");

      vm.stopPrank();

    }

    function test_getFundsBackOnICOFail_2() public
    {
        vm.startPrank(USER1);
        vm.warp(startTime + 1);

        uint256 val = 0.01 ether;
        mico.buyTokens{value: val}();

        mico.buyTokens{value: val}();
        vm.stopPrank();

        vm.prank(USER2);
        mico.buyTokens{value: val}();

        vm.warp(endTime + 1);

        vm.prank(USER3);
        vm.expectRevert("Not funds found");
        mico.getFundsBackOnICOFail();

        vm.prank(USER1);
        uint256 balanceBefore = address(USER1).balance;
        mico.getFundsBackOnICOFail();
        uint256 balanceAfter = address(USER1).balance;

        require(balanceAfter - balanceBefore == 2 * val, "All funds must be return 1");

        vm.prank(USER2);
        uint256 balanceBefore2 = address(USER2).balance;
        mico.getFundsBackOnICOFail();
        uint256 balanceAfter2 = address(USER2).balance;

        require(balanceAfter2 - balanceBefore2 == val, "All funds must be return 2");


    }

}