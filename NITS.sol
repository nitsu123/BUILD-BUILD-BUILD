// SPDX-License-Identifier: GPL-3.0

pragma solidity >0.8.0 <= 0.9.0;

contract NITS {
     address public owner;
     uint totalSupply;
    

     event Transferred(address indexed _from, uint _amountTransferred, address indexed _to);
    
     mapping(address => uint) public balances;

     constructor() {
        owner = msg.sender;
     }

     function transfer(uint _amount, address _receiver) public {
        require(_amount > 0, "invalid amnunt");
        require(_receiver != address(0), "invalid address");
        require(_amount <= balances[msg.sender], "insufficient balance");

        balances[msg.sender] -= _amount;
        balances[_receiver] += _amount;

        emit Transferred(msg.sender, _amount, _receiver);
     }

     function mint(uint _amount) public {
        require(msg.sender == owner, "not the owner");
        require(_amount > 0, "invalid mint amount");

        balances[owner] += _amount;
        totalSupply += _amount;
     }
}