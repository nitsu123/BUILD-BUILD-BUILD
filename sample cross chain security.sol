//SPDX-License-Identifier: MIT
pragma solidity >0.8.0 <= 0.9.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

interface ILockableNFT is IERC721, IERC721Metadata {
    function lock(uint256 tokenId) external;
    function mint(address to, uint256 tokenId) external; // Add mint function
}

contract NFTBridge {

    mapping(bytes32 => bool) public processedMessages;

    event NFTLocked(address nft, uint256 tokenId, uint256 chainId);

    function initiateBridge(address nft, uint256 tokenId, uint256 targetChain) external {
        require(IERC721(nft).ownerOf(tokenId) == msg.sender, "Not owner");

        ILockableNFT(nft).lock(tokenId);

        emit NFTLocked(nft, tokenId, targetChain);
    }

    function completeBridge(
        bytes32 messageId,
        address nft,
        uint256 tokenId,
        address recipient
    ) external {
        require(!processedMessages[messageId], "Already processed");

        processedMessages[messageId] = true;

        ILockableNFT(nft).mint(recipient, tokenId); // or wrapper mint
    }
}