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

    mapping(address => Data[]) public stakeData;

    struct Data {
        uint amount;
        uint startTime;
        bool claimed;

    }

    function stake(uint _amount) external returns (bool) {
        require(_amount > 0, "invalid amount");
        token.transferFrom(msg.sender, address(this), _amount);
        stakeData[msg.sender].push(Data({amount: _amount, startTime: block.timestamp, claimed: false}));


        return true;
    }

    function withdraw(uint _stakeNumber) external returns (bool) {
        Data storage staked = stakeData[msg.sender][_stakeNumber];
        require(_stakeNumber < stakeData[msg.sender].length , "invalid index");
        require(staked.amount > 0, "you dont have any staked tokens");
        require(!staked.claimed, "rewards already claimed");


        if (block.timestamp > staked.startTime + lockTime) {
        uint reward = (staked.amount * rewardRate) / 100;
        uint withdrawable = reward + staked.amount;
        staked.claimed = true;
        staked.amount = 0;

        bool success = token.transfer(msg.sender, withdrawable);
        require(success, "withdraw failed");
        }

        else {
        uint penalty = (staked.amount * 10) /100;
        uint total = staked.amount - penalty;

        staked.claimed = true;
        staked.amount = 0;

        bool success = token.transfer(msg.sender, total);
        require(success, "withdraw failed");

        }
        return true;
        }
}
