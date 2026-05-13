// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
pragma solidity >0.8.0 <=0.9.0;
        
        event Transfer(address indexed from, address indexed to, uint amount);

contract LendingDapp {
    address public owner;
    IERC20 public token;
    uint colPercentage = 50;
    uint totalLiquidity;

    mapping(address => Position) public positions;

    struct Position {
        address user;
        uint collateral;
        uint debt;
        bool locked;
    }

    constructor(address _token) {
        owner = msg.sender;
        token = IERC20(_token);
    }

    function addCollateral(uint _amount) public {
        require(_amount > 0, "invalid amount");
        uint currentCollateral = positions[msg.sender].collateral;
        uint currentDebt = positions[msg.sender].debt;
        IERC20(token).transferFrom(msg.sender, address(this), _amount);


        positions[msg.sender] = Position({user: msg.sender, collateral: currentCollateral +_amount, debt: currentDebt, locked: true});

        emit Transfer(msg.sender ,address(this), _amount);
    }
    function borrowAsset(uint _amount) public {
        require(_amount > 0, "invalid amount");
        require(positions[msg.sender].locked, "assets not yet locked");

        uint maxBorrow = (positions[msg.sender].collateral * colPercentage) / 100;
        uint currentDebt = positions[msg.sender].debt;
        uint addedDebt = currentDebt + _amount;

        require(_amount <= maxBorrow, "insufficient borrowing power");
        require(addedDebt <= maxBorrow, "insuficient borrowing power");
        positions[msg.sender] = Position({user: msg.sender, collateral: positions[msg.sender].collateral, debt: addedDebt, locked: true});

        IERC20(token).transfer(msg.sender, _amount);

        emit Transfer(address(this), msg.sender, maxBorrow);
    }
    function rePay(uint _amount) public {
        require(positions[msg.sender].debt > 0, "you do not owe anything");
        require(_amount > 0, "cannot pay zero");
        
        uint currentDebt = positions[msg.sender].debt;
        require(_amount <= currentDebt, "invalid repay amount");
        IERC20(token).transferFrom(msg.sender ,address(this), _amount);
        uint updatedDebt = currentDebt - _amount;

        if(_amount == currentDebt) {
        positions[msg.sender] = Position({user: msg.sender, collateral: positions[msg.sender].collateral, debt: updatedDebt, locked: false});
        }
        else {
        positions[msg.sender] = Position({user: msg.sender, collateral: positions[msg.sender].collateral, debt: updatedDebt, locked: true});
        }
        emit Transfer(msg.sender, address(this), _amount);
    }

    function withdrawCollateral(uint _amount) public {
        uint collateral = positions[msg.sender].collateral;
        require(!positions[msg.sender].locked, "assets still locked, canno withdraw");
        require(_amount <= collateral, "invalid amount");
        require(_amount > 0, "invalid amouunt");
        require(positions[msg.sender].debt == 0, "you still have a debt to pay, cannot withdraw");

        uint newCollateral = positions[msg.sender].collateral - _amount;
        positions[msg.sender] = Position({user: msg.sender, collateral: newCollateral, debt: positions[msg.sender].debt, locked: false});
        delete positions[msg.sender];

        IERC20(token).transfer(msg.sender, _amount);

        emit Transfer(address(this), msg.sender, _amount);

    }




}