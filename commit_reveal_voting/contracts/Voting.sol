// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;


contract Voting
{

    uint public num_of_options;
    uint public commit_start;
    uint public commit_end;
    uint public reveal_start;
    uint public reveal_end;

    uint[] vote_result;

    mapping(address => bytes32) public commits;
    mapping(address => bool) public voted;


    modifier goodOption(uint num) {
        require(num < num_of_options, "Wrong num");
        _;
    }

    modifier inProgressCommit() {
        require(commit_start <= block.timestamp && block.timestamp <= commit_end, "Commit is not in progress");
        _;
    }

    modifier inProgressReveal() {
        require(reveal_start <= block.timestamp && block.timestamp <= reveal_end, "Reveal is not in progress");
        _;
    }

    constructor(uint _num_of_option, uint _commit_start, uint _commit_end, uint _reveal_start, uint _reveal_end) 
    {
        num_of_options = _num_of_option;
        commit_start = _commit_start;
        commit_end = _commit_end;
        reveal_start = _reveal_start;
        reveal_end = _reveal_end;

        vote_result = new uint[](num_of_options);
    }


    function commit(bytes32 _commitment) external inProgressCommit {
        require(commits[msg.sender] == 0, "Already committed");
        require(_commitment != 0, "Empty committed");
        commits[msg.sender] = _commitment;
    }

    function reveal(uint256 _value, uint256 _salt) external goodOption(_value) inProgressReveal {       
        require(keccak256(abi.encodePacked(_value, _salt)) == commits[msg.sender], "Invalid commit");

        if (voted[msg.sender] == true) {
            revert("Already vote");
        }
        
        voted[msg.sender] = true;
        vote_result[_value]++;
    }    

    function createCommitment(uint _value, uint _salt) external pure returns(bytes32)
    {
        return keccak256(abi.encodePacked(_value, _salt));
    }

    function getResult() external view returns (uint[] memory)
    {
        return vote_result;
    }

    function getCommited() external view returns(bool)
    {
        return commits[msg.sender] != 0x0;
    }

    function getVoted() external view returns(bool)
    {
        return voted[msg.sender];
    }

    function getInProgressCommit() external view returns(bool)
    {
        return commit_start <= block.timestamp && block.timestamp <= commit_end;
    }

    function getInProgressReveal() external view returns(bool)
    {
        return reveal_start <= block.timestamp && block.timestamp <= reveal_end;
    }
}

