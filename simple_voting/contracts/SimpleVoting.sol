// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract SimpleVoting
{
    uint public num_of_options;
    uint public vote_start;
    uint public vote_end;

    uint[] vote_result;

    mapping(address => bool) voted;
    mapping(address => address) delegated;


    modifier goodOption(uint num) {
        require(num < num_of_options, "Wrong num");
        _;
    }

    modifier notZeroAddress(address addr) {
        require(addr != address(0), "Empty address not allowed");
        _;
    }

    modifier inProgress() {
        require(vote_start <= block.timestamp && block.timestamp <= vote_end, "Vote is not in progress");
        _;
    }

    constructor(uint _num_of_option, uint _vote_start, uint _vote_end) 
    {
        num_of_options = _num_of_option;
        vote_start = _vote_start;
        vote_end = _vote_end;

        vote_result = new uint[](num_of_options);
    }

    function vote(uint option_num) external goodOption(option_num) inProgress
    {
        if (voted[msg.sender] == true) {
            revert("Already vote");
        }
        voted[msg.sender] = true;
        vote_result[option_num]++;
    }

    function delegate(address to) external notZeroAddress(to)
    {
        delegated[msg.sender] = to;
    }

    function delegateVote(address from, uint option_num) external goodOption(option_num) notZeroAddress(from) inProgress
    {
        if (voted[from] == true) {
            revert("Already vote");
        }
        if (delegated[from] != msg.sender) {
            revert("Not delegated");
        }
        voted[from] = true;
        vote_result[option_num]++;
    }

    function getResult() external view returns (uint[] memory)
    {
        return vote_result;
    }

    function getVoted() external view returns(bool)
    {
        return voted[msg.sender];
    }

    function getDelegateTo() external view returns(address)
    {
        return delegated[msg.sender];
    }

    function getInProgress() external view returns(bool)
    {
        return vote_start <= block.timestamp && block.timestamp <= vote_end;
    }
}