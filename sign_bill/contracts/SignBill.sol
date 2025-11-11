// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract SignBill 
{
    address public owner;

    mapping (uint bill_num => bool payed) bill_payed;

    constructor () payable 
    {
        require(msg.value > 0, "Must be payed");
        owner = msg.sender;
    }

    function recieve() external payable 
    {
        require(msg.value > 0, "Must be payed");
    }

    function pay_bill(uint bill_num, uint amount, bytes memory signature) external 
    {
        require(!bill_payed[bill_num], "bill already payed");

        bill_payed[bill_num] = true;

        bytes32 message = withPrefix(keccak256(abi.encodePacked(
            msg.sender,
            amount,
            bill_num,
            address(this)
        )));

        require(
            recoverSigner(message, signature) == owner, "invalid signature!"
        );

        payable(msg.sender).transfer(amount);
    }

    function createMessage(address to, uint amount, uint bill_num) public view returns(bytes32)
    {
        bytes32 message = withPrefix(keccak256(abi.encodePacked(
            to,
            amount,
            bill_num,
            address(this)
        )));

        return message;
    }

    function splitSignature(bytes memory signature) private pure returns(bytes32 r, bytes32 s, uint8 v) 
    {
        require(signature.length == 65, "Wrong signature");

        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }

        return (r, s, v);
    }

    function withPrefix(bytes32 _hash) private pure returns(bytes32) 
    {
        return keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                _hash
            )
        );
    }


    function recoverSigner(bytes32 message, bytes memory signature) private pure returns(address) 
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature);
        return ecrecover(message, v, r, s);
    }

}

