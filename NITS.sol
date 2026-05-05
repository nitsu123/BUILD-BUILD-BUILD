// SPDX-License-Identifier: GPL-3.0

pragma solidity >0.8.0 <= 0.9.0;

contract NITS {
     address public owner;
     uint public totalSupply;
    

     event Transfer(address indexed _from, address indexed _to, uint amount);
     event Approval(address indexed owner, address indexed spender, uint amount); 


     mapping(address => uint) public balances;
     mapping(address => mapping(address => uint)) public allowances;

     constructor() {
        owner = msg.sender;
     }

     function transfer(address to, uint amount) external returns(bool) {
        require(amount > 0, "invalid amnunt");
        require(to != address(0), "invalid address");
        require(amount <= balances[msg.sender], "insufficient balance");

        balances[msg.sender] -= amount;
        balances[to] += amount;

        emit Transfer(msg.sender, to, amount);

        return true;
     }

     function approve(address spender, uint amount) external returns (bool) {
         require(spender != address(0), "invalid address");

         allowances[msg.sender][spender] = amount;

         emit Approval(msg.sender, spender, amount);

         return true;
     }

      function transferFrom(address  from, address to, uint amount) external returns (bool) {
       require(allowances[from][msg.sender] >= amount, "invalid amount");
       require(amount > 0, "invalid amount");
       require(amount <= balances[from],"dont have enough balances");
       require(to != address(0), "blank address");

       balances[from] -= amount;
       balances[to] += amount;

       allowances[from][msg.sender] -= amount;
       
       emit Transfer(from, to, amount);

       return true;
       }

     function mint(uint amount) external {
        require(msg.sender == owner, "not the owner");
        require(amount > 0, "invalid mint amount");

        balances[owner] += amount;
        totalSupply += amount;

        emit Transfer(address(0), owner, amount);
     }
}
