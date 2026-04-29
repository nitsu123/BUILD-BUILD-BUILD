// SPDX-License-Identifier: GPL-3.0

pragma solidity >0.8.0 <=0.9.0;

contract Subscription {
    address public owner;
    address public subscriber;
    uint public price = 1 ether;
    uint public expiry;
    uint public duration = 7 days;

    constructor() {
        owner = msg.sender;
    }

    function subscribe() public payable {
        require(subscriber == address(0), "already subscribed");
        require(msg.value == price, "please provide exact amount");
        subscriber = msg.sender;
        expiry = block.timestamp + duration;
    }

    function isActive() public view returns (bool) {
        require(msg.sender == subscriber, "not a subscriber");
        return block.timestamp < expiry && subscriber == msg.sender;
    }

    function renew() public payable  {
        require(subscriber == msg.sender, "not a subscriber");
        require(msg.value == price, "please provide the exact amount");
        if(block.timestamp < expiry) {
             expiry = expiry + duration;
        }
             else {
                expiry = block.timestamp + duration;
             }
    }
    function withdraw() public {
        require(msg.sender == owner, "only owner can withdraw the funds");
        (bool success, ) = payable(owner).call{value: address(this).balance}("");
        require(success, "transfer failed");
    }

    function cancelSub() public {
        require(msg.sender == subscriber, "you need to be a subcriber to cancel");
        subscriber = address(0);
    }

}