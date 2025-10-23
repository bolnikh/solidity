// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import './MyToken.sol';

contract MyICO
{
    MyToken mt;
    bool mt_deployed;

    uint256 price;

    address owner;

    uint256 hard_cap;
    uint256 soft_cap;

    uint256 startTime;
    uint256 endTime;

    mapping (address => uint256) funds;

    bool ico_finished;


    event TokenDeployed(address tokenAddress);
    event TokensPurchased(address indexed buyer, uint256 amount);

    modifier isOwner() {
        require(owner == msg.sender, "Only owner allowed");
        _;
    }

    modifier inProgress() {
        require(block.timestamp >= startTime, "ICO not started");
        require(block.timestamp <= endTime, "ICO ended");
        require(address(this).balance - msg.value <= hard_cap, "Funds is already enought");
        require(ico_finished == false, "ICO finished");
        _;
    }

    modifier icoSucccess() {
        require(address(this).balance >= soft_cap, "Not enought funds");
        _;
    }

    modifier icoFailed() {
        require(block.timestamp >= endTime, "ICO not ended");
        require(address(this).balance < soft_cap, "Have enought funds");
        _;
    }

    modifier icoNotFinished() {
        require(ico_finished == false, "ICO finished");
        _;
    }

    constructor (uint256 _price, uint256 _soft_cap, uint256 _hard_cap, uint256 _startTime, uint256 _endTime)     
    {
        owner = msg.sender;

        price = _price;
        hard_cap = _hard_cap;
        soft_cap = _soft_cap;
        startTime = _startTime;
        endTime = _endTime;
    }

    
    function buyTokens() external payable inProgress
    {
        require(msg.value >= price, "Send enough ether to join");
        uint256 token_amount = msg.value / price;

        mt.mint(msg.sender, token_amount);

        funds[msg.sender] += msg.value;

        emit TokensPurchased(msg.sender, token_amount);
    } 

    function withdrawFunds() external isOwner icoSucccess
    {
        ico_finished = true;
        (bool sent, ) = payable(owner).call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }

    function getFundsBackOnICOFail() external icoFailed
    {
        require(funds[msg.sender] > 0, "Not funds found");
        (bool sent, ) = payable(msg.sender).call{value: funds[msg.sender]}("");
        require(sent, "Failed to send Ether");
    }

    function getInProgress() external view returns (bool)
    {
        return  block.timestamp >= startTime
                && block.timestamp <= endTime
                && address(this).balance <= hard_cap
                && ico_finished == false;
    }

    function getICOStarted() external view returns (bool)
    {
        return  block.timestamp >= startTime;
    }    

    function getICOFailed() external view returns (bool)
    {
        return  block.timestamp >= endTime
                && address(this).balance < soft_cap;
    }   

    function deployToken(
        string memory _name, 
        string memory _symbol
    ) external isOwner returns (MyToken) {
        require(!mt_deployed, "Token already deployed");
        
        mt = new MyToken(address(this), _name, _symbol);
        mt_deployed = true;
        
        emit TokenDeployed(address(mt));

        return mt;
    }

    function getToken() external view returns (MyToken)
    {
        return mt;
    }

    function getIsOwner() external view returns (bool) {
        return owner == msg.sender;
    }    
}