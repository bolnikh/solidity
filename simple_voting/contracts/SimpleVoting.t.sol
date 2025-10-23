// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {SimpleVoting} from "./SimpleVoting.sol";
import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";


contract SimpleVotingTest is Test 
{
  SimpleVoting simple_voting;

  uint num_of_options;
  uint vote_start;
  uint vote_end;    

  address constant USER1 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
  address constant USER2 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
  address constant USER3 = 0x90F79bf6EB2c4f870365E785982E1f101E93b906;
  address constant USER4 = 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65;

  function setUp() public 
  {
    num_of_options = 3;
    vote_start = block.timestamp + 10;
    vote_end = block.timestamp + 60;
    simple_voting = new SimpleVoting(num_of_options, vote_start, vote_end);
  }

  function test_InitialValue() public view
  {
    require(simple_voting.num_of_options() == num_of_options, "Wrong Initial value num_of_options");
    require(simple_voting.vote_start() == vote_start, "Wrong Initial value vote_start");
    require(simple_voting.vote_end() == vote_end, "Wrong Initial value vote_end");

    uint[] memory res =  simple_voting.getResult();
    for (uint i; i < res.length; i++) {
      if (res[i] != 0) {
        revert("Initial val must be 0");
      }
    }    
  }

  function test_voteTime() public 
  {
    vm.expectRevert("Vote is not in progress");
    simple_voting.vote(0);

    vm.warp(11);
    simple_voting.vote(0);

    vm.warp(100);
    vm.expectRevert("Vote is not in progress");
    simple_voting.vote(0);

  }

  function test_ZeroAddress() public
  {
    address addr = address(0);

    vm.expectRevert("Empty address not allowed");
    simple_voting.delegate(addr);
  }

  function test_goodOption() public
  {
    vm.warp(11);

    simple_voting.vote(num_of_options - 1);

    vm.expectRevert("Wrong num");
    simple_voting.vote(num_of_options);
  }

  function test_vote() public
  {
    vm.warp(11);
    uint op = 0;
    uint op1 = 1;
    simple_voting.vote(op);

    uint[] memory res = simple_voting.getResult();
    require(res[op] == 1, "Vote not registered");

    vm.expectRevert("Already vote");
    simple_voting.vote(op);   

    vm.prank(USER1);
    simple_voting.vote(op);

    vm.prank(USER2);
    simple_voting.vote(op);

    res = simple_voting.getResult();
    require(res[op] == 3, "Vote not registered");

    vm.prank(USER3);
    simple_voting.vote(op1);

    res = simple_voting.getResult();
    require(res[op1] == 1, "Vote not registered");    
  }

  function test_delegate() public
  {
    uint op = 0;

    vm.warp(11);
    vm.prank(USER1);
    simple_voting.delegate(USER2);

    vm.expectRevert("Not delegated");
    vm.prank(USER3);
    simple_voting.delegateVote(USER1, op);

    vm.prank(USER2);
    simple_voting.delegateVote(USER1, op); 

    vm.prank(USER4);
    simple_voting.delegate(USER2);

    vm.prank(USER2);
    simple_voting.delegateVote(USER4, op);

    uint[] memory res = simple_voting.getResult();
    require(res[op] == 2, "Vote not registered");                   
  }

}