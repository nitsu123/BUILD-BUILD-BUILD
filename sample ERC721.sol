// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LockableNFT is ERC721URIStorage, Ownable {
    
    uint256 public nextTokenId;

    mapping(uint256 => bool) public locked;

    modifier notLocked(uint256 tokenId) {
        require(!locked[tokenId], "NFT is locked");
        _;
    }

    constructor() ERC721("LockableNFT", "LNFT") Ownable(msg.sender) {}

    function mint(address to, string memory uri) external onlyOwner {
        uint256 tokenId = nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // 🔒 lock NFT (called by marketplace/bridge)
    function lock(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender || msg.sender == owner(), "Not authorized");
        locked[tokenId] = true;
    }

    function unlock(uint256 tokenId) external onlyOwner {
        locked[tokenId] = false;
    }

    // override transfer to block locked NFTs
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override notLocked(tokenId) returns (address) {
        return super._update(to, tokenId, auth);
    }
}