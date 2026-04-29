// SPDX-License-Identifier: GPL-3.0

pragma solidity >0.8.0 <=0.9.0;

contract VotimgSystem {
    address public owner;

    struct Proposal {
        string name;
        uint voteCount;
    }

    Proposal[] public proposals;

    mapping(address => bool) hasVoted;

    modifier onlyOwner() {
        require(msg.sender == owner, "not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createProposal(string memory _name) public payable {
        proposals.push(Proposal(_name, 0));
    }

    function voteCount(uint _proposalCount) public payable {
        require(!hasVoted[msg.sender], "already voted");
        require(_proposalCount < proposals.length, "invalid proposal!");
            proposals[_proposalCount].voteCount++;
            hasVoted[msg.sender] = true;


    }
}