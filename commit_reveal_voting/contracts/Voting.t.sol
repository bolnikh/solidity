// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Voting} from "./Voting.sol";
import {Test} from "forge-std/Test.sol";

contract VotingTest is Test {
  Voting voting;

  uint num_of_options;
  uint commit_start;
  uint commit_end;
  uint reveal_start;
  uint reveal_end;

  address constant USER1 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
  address constant USER2 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
  address constant USER3 = 0x90F79bf6EB2c4f870365E785982E1f101E93b906;
  address constant USER4 = 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65;

  bytes32 b = 0x5b07e077a81ffc6b47435f65a8727bcc542bc6fc0f25a56210efb1a74b88a5ae; // exmple
  function setUp() public {

    num_of_options = 3;
    commit_start = block.timestamp + 10;
    commit_end = block.timestamp + 60;
    reveal_start = block.timestamp + 100;
    reveal_end = block.timestamp + 200;
    
    voting = new Voting(
        num_of_options,
        commit_start,
        commit_end,
        reveal_start,
        reveal_end
    );
  }

  function test_InitialValue() public view
  {
    require(voting.num_of_options() == num_of_options, "Wrong Initial value num_of_options");
    require(voting.commit_start() == commit_start, "Wrong Initial value commit_start");
    require(voting.commit_end() == commit_end, "Wrong Initial value commit_end");
    require(voting.reveal_start() == reveal_start, "Wrong Initial value reveal_start");
    require(voting.reveal_end() == reveal_end, "Wrong Initial value reveal_end");

    uint[] memory res =  voting.getResult();
    for (uint i; i < res.length; i++) {
      if (res[i] != 0) {
        revert("Initial val must be 0");
      }
    }    
  }

  function test_commitTime() public 
  {
    vm.expectRevert("Commit is not in progress");
    voting.commit(b);

    vm.warp(11);

    vm.expectRevert("Empty committed");
    voting.commit(0x0);

    voting.commit(b);

    vm.warp(100);
    vm.expectRevert("Commit is not in progress");
    voting.commit(b);    
  }

  function test_revealTime() public 
  {
    vm.expectRevert("Reveal is not in progress");
    voting.reveal(0, 0);

    vm.warp(101);

    vm.expectRevert("Invalid commit");
    voting.reveal(0, 0);

    vm.warp(100);  
    vm.expectRevert("Reveal is not in progress");
    voting.reveal(0, 0);      
  }

  function test_commitReveal() public
  {
    vm.warp(11);

    bytes32 com1 = voting.createCommitment(1, 100);
    voting.commit(com1);

    vm.warp(101);

    voting.reveal(1, 100);

    uint[] memory res = voting.getResult();

    require(res[1] == 1, "Wrong vote");
  }


  function test_alreadyCommited() public
  {
    vm.warp(11);

    bytes32 com1 = voting.createCommitment(1, 100);
    voting.commit(com1);

    vm.expectRevert("Already committed");
    voting.commit(com1);
  }

  function test_emptyCommited() public
  {
    vm.warp(11);

    vm.expectRevert("Empty committed");
    voting.commit(0x0);
  }

  function test_vote() public
  {
    vm.warp(11);

    bytes32 com1 = voting.createCommitment(1, 100);
    vm.prank(USER1);
    voting.commit(com1);

    
    bytes32 com2 = voting.createCommitment(1, 1000);
    vm.prank(USER2);
    voting.commit(com2);  


    bytes32 com3 = voting.createCommitment(2, 10000);
    vm.prank(USER3);
    voting.commit(com3);

    bytes32 com4 = voting.createCommitment(0, 1000);
    vm.prank(USER4);    
    voting.commit(com4);


    vm.warp(101);
    
    vm.prank(USER1);
    voting.reveal(1, 100);

    vm.prank(USER2);
    voting.reveal(1, 1000);

    vm.prank(USER3);
    voting.reveal(2, 10000);

    vm.prank(USER4);
    voting.reveal(0, 1000);

    uint[] memory res = voting.getResult();

    require(res[0] == 1, "Wrong vote result 1");              
    require(res[1] == 2, "Wrong vote result 2");              
    require(res[2] == 1, "Wrong vote result 3");              
  }

}