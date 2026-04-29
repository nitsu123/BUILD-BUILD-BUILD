// SPDX-License-Identifier: MIT
pragma solidity >0.8.0 <=0.9.0;

contract Escrow {
    address buyer;
    address seller;
    uint amount;
    bool funded;
    bool approved;
    bool withdrawn;

    constructor() {
        buyer = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        seller = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    }

    function fund() public payable {
        require(buyer == msg.sender, "not the buyer");
        require(!funded, "already funded");
        require(msg.value > 0, "amount invalid");
        amount = msg.value;
        funded = true;
    }

    function approve() public payable {
        require(buyer == msg.sender, "not the buyer");
        require(funded == true, "not yet funded");
        require(!approved, "already aproved");
        approved = true;
    }

    function withdraw() public payable  {
        require(msg.sender == seller, "not the seler");
        require(approved == true, "not yet approved");
        require(!withdrawn, "already withdrawn");
        (bool success, ) =  payable(seller).call{value: amount}("transfer success!");
        require(success == true, "transfer failed");
        withdrawn =  true;

    }

}