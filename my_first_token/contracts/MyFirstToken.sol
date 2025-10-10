// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract MyFirstToken 
{
    string public name;
    string public symbol;
    uint public decimals;
    uint public totalSupply = 0;
    mapping (address owner => uint amount) balance;
    mapping (address owner => mapping(address spender => uint amount)) allow;

    /// who can mint and burn
    address admin;


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    modifier nonZeroAddress(address _addr) {
        require(_addr != address(0), "Require non zero address");
        _;
    }

    modifier positive(uint _value) {
        require(_value > 0, "Value must be positive");
        _;
    }

    modifier isAdmin() {
        require(msg.sender == admin, "Must be admin");
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        uint _decimals,
        address _admin
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        admin = _admin;
    }

    function balanceOf(address _owner) public view nonZeroAddress(_owner) returns (uint success) 
    {
        return balance[_owner];
    }


    function transfer(address _to, uint256 _value) external nonZeroAddress(_to) positive(_value) returns (bool success) 
    {
        require(balanceOf(msg.sender) >= _value, "Not enought balance");
        balance[msg.sender] -= _value;
        balance[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;        
    }

    function approve(address _spender, uint256 _value) external nonZeroAddress(_spender) positive(_value) returns(bool success)
    {
        allow[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }


    function transferFrom(address _from, address _to, uint256 _value) external nonZeroAddress(_from) nonZeroAddress(_to) positive(_value) returns(bool success)
    {
        uint _allow = allowance(_from, msg.sender);
        require(_allow >= _value, "Allowance must be enought");
        
        allow[_from][msg.sender] = _allow - _value;

        balance[_from] -= _value;
        balance[_to] += _value;

        return true;  
    }

    function allowance(address _owner, address _spender) public view returns (uint256) 
    {
        return allow[_owner][_spender];
    }

    function adminMint(address _to, uint256 _value) external isAdmin nonZeroAddress(_to) positive(_value) returns (bool success) 
    {
        balance[_to] += _value;
        totalSupply += _value;
        return true;        
    }

    function adminBurn(address _to, uint256 _value) external isAdmin nonZeroAddress(_to) positive(_value) returns (bool success) 
    {
        require(balanceOf(_to) >= _value, "Not enought balance");
        balance[_to] -= _value;
        totalSupply -= _value;
        return true;        
    }

    function getTotalSupply() external view returns (uint256) 
    {
        return totalSupply;
    }

    function getIsAdmin() external view returns (bool) 
    {
        return msg.sender == admin;
    }

    function getName() external view returns (string memory) 
    {
        return name;
    }

    function getSymbol() external view returns (string memory) 
    {
        return symbol;
    }

    function getDecimals() external view returns (uint256) 
    {
        return decimals;
    }        
}