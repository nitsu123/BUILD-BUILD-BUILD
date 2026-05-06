// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.20;

interface IERC20 { 
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint amount) external returns (bool);
    function balanceOf(address account) external view returns (uint);
}

contract Staking {
    address public owner;
    IERC20 public token;
    uint lockTime = 30 days;
    uint rewardRate = 15;


    constructor(address _token) payable {
        owner = msg.sender;
        token = IERC20(_token);
    }

    mapping(address => Data) public stakeData;

    struct Data {
        uint amount;
        uint startTime;
        bool claimed;

    }

    function stake(uint _amount) external returns (bool) {
        require(_amount > 0, "invalid amount");
        token.transferFrom(msg.sender, address(this), _amount);
        stakeData[msg.sender] = (Data({amount: _amount, startTime: block.timestamp, claimed: false}));


        return true;
    }

    function withdraw() external returns (bool) {
        require(stakeData[msg.sender].amount > 0, "you dont have any staked tokens");
        require(!stakeData[msg.sender].claimed, "rewards already claimed");
        require(block.timestamp > stakeData[msg.sender].startTime + lockTime, "30 days hasnt passed");

        uint reward = (stakeData[msg.sender].amount * rewardRate) / 100;
        uint withdrawable = reward + stakeData[msg.sender].amount;
        stakeData[msg.sender].claimed = true;

        token.transfer(msg.sender, withdrawable);

        return true;
        }
}