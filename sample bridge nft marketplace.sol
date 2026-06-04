// SPDX-License-Identifier: GPL3.0

pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface ILockableNFT is IERC721 {
    function lock(uint256 tokenId) external;
}

contract NFTMarketplace is ReentrancyGuard {


    mapping(uint256 => Listing) public listings;

    struct Listing {
        address seller;
        address nft;
        uint256 tokenId;
        uint256 price;
        bool active;
    }

    uint256 public listingId;



    //  prevent same NFT being listed twice
    mapping(address => mapping(uint256 => bool)) public isListed;

    event Listed(uint256 id, address nft, uint256 tokenId, uint256 price);
    event Bought(uint256 id, address buyer);

    function listNFT(address nft, uint256 tokenId, uint256 price) external {
           require(!isListed[nft][tokenId], "Already listed");

     IERC721(nft).transferFrom(msg.sender, address(this), tokenId);

        listings[listingId] = Listing({
            seller: msg.sender,
            nft: nft,
            tokenId: tokenId,
            price: price,
            active: true
        });

        isListed[nft][tokenId] = true;

        // lock NFT so it can't be double sold or moved
        ILockableNFT(nft).lock(tokenId);

        emit Listed(listingId, nft, tokenId, price);
        listingId++;
    }

    function buyNFT(uint256 id) external payable nonReentrant {
        Listing storage item = listings[id];
        require(item.active, "Inactive listing");
        require(msg.value >= item.price, "Insufficient payment");

        item.active = false;
        isListed[item.nft][item.tokenId] = false;

        // transfer NFT to buyer
        IERC721(item.nft).transferFrom(address(this), msg.sender, item.tokenId);

        // pay seller
        (bool success, ) = (item.seller).call{value: item.price}("");
        require(success, "transfer failed");

        emit Bought(id, msg.sender);
    }

    function cancelListing(uint256 id) external {
        Listing storage item = listings[id];
        require(msg.sender == item.seller, "Not seller");
        require(item.active, "Already inactive");

        item.active = false;
        isListed[item.nft][item.tokenId] = false;


        IERC721(item.nft).transferFrom(address(this), item.seller, item.tokenId);
    }
}