// SPDX-License-Identifier: GPL-3.0


pragma solidity >0.8.0 <= 0.9.0;

contract Marketplace{
    address public owner;
    uint itemCounter;
    
    event ItemListed(uint itemId,uint itemPrice, address sellerAddress);
    event ItemBought(uint itemId, uint itemPrice, address buyerAddress);
    event ItemCancelled(uint itemId);

    mapping(uint => Items) public ids;

    struct Items{
        address buyer;
        address seller;
        uint price;
        bool status;
        bool cancelled;
    }

    constructor() {
        owner = msg.sender;
    }

    function listItem(uint _price) public payable {
        itemCounter++;
        require(_price >= 1 ether, "floor price starts at 1 eth!");
        ids[itemCounter] = Items({seller: msg.sender, buyer: address(0), price: _price, status: false, cancelled: false });
        emit ItemListed(itemCounter, _price, msg.sender);
    }

    function buyItem(uint id) public payable{
        require(msg.sender != ids[id].seller, "this address is not alowed to buy this item");
        require(ids[id].seller != address(0), "item does not exist");
        require(!ids[id].cancelled, "item already cancelled");
        uint price = ids[id].price;
        require(msg.value == price, "exact price needed to buy the item");
        require(!ids[id].status, "already sold");
        ids[id].buyer = msg.sender;
        ids[id].status = true;
        (bool success, ) = (ids[id].seller).call{value: price}("");
        require(success == true, "buy failed");

        emit ItemBought(id, price, msg.sender);
    }

    function cancelitem(uint id) public {
        require(msg.sender == ids[id].seller, "only seller can cancel their listing");
        require(!ids[id].status, "item already sold");
        require(ids[id].seller != address(0), "cannot execute");
        require(!ids[id].cancelled, "item has been already cancelled before");
        ids[id].buyer = address(0);        
        ids[id].cancelled = true;

        emit ItemCancelled(id);
    }
    
}