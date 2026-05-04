//SPDX-License-Identifier: GPL-3.0

pragma solidity >0.8.0 <= 0.9.0;

contract Multisig{

    mapping(address => bool) public isOwner;

    uint transactionCount;
     
    struct Proposal {
        address destination;
        uint value;
        bool executed;
        uint approvalCount;
    }

    constructor () {
        isOwner[0x5B38Da6a701c568545dCfcB03FcB875f56beddC4] = true;
        isOwner[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2] = true;
        isOwner[0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db] = true;
    }

    mapping(uint => mapping(address => bool)) public approvals;
    mapping(uint => Proposal) public transactions;

    function createProposal(uint _value, address _destination) public {
        require(isOwner[msg.sender] == true, "not an owner");
        transactionCount++;
        require(_value > 0 , "invalid amount");
        transactions[transactionCount] = (Proposal({destination: _destination, value: _value, executed: false, approvalCount: 0}));

    }

    function approveProposal(uint _txId) public {
        require(isOwner[msg.sender] == true, "not an owner");
        require(transactions[_txId].executed == false, "transaction has already been executed");
        require(approvals[_txId][msg.sender] == false, "aleady approved");

        approvals[_txId][msg.sender] = true;
        transactions[_txId].approvalCount ++;
    }

    function executeProposal(uint _txId) public{
        require(isOwner[msg.sender] == true, "not an owner");
        require(transactions[_txId].executed == false, "transaction has already been executed");
        uint requiredApproval = 2;
        require(transactions[_txId].approvalCount >= requiredApproval, "you need more approvals to execute this function");

        transactions[_txId].executed = true;

        (bool success, ) = payable(transactions[_txId].destination).call{value: transactions[_txId].value} ("");
        require(success, "execution failed");

    }
}
