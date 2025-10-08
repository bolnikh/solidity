//SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;


contract SimpleBank {

    mapping(address account => uint amount) accounts;

    event Deposited(address indexed account, uint amount);
    event Withdrawn(address indexed account, uint amount);

    constructor() {

    }

    function deposit() external payable {
        require(msg.sender != address(0), "Require non zero address");
        require(msg.value > 0, "Require non zero amount");

        accounts[msg.sender] += msg.value;

        emit Deposited(msg.sender, msg.value);
    }

    function withdraw(uint amount) external {
        require(msg.sender != address(0), "Require non zero address");
        require(amount > 0, "Require non zero amount");
        require(accounts[msg.sender] >= amount, "Not enough balance");

        accounts[msg.sender] -= amount;

        (bool success, ) = payable(msg.sender).call{value: amount}("");        
        require(success, "Transfer failed");

        emit Withdrawn(msg.sender, amount);
    }

    function getBalance() external view returns (uint) {
        return accounts[msg.sender];
    }

}
