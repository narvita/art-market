// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract AssetMarket is ERC721{
    address owner;
    struct contractAdress {
        address token;
        uint256 price;
    }

    mapping (address => contractAdress[]) assets;


    constructor() ERC721("Asset", "AS") {
        owner = msg.sender; 
    }

    modifier OnlyOwner() {
        require(msg.sender == owner, "You are not an owner");
        _;
    }

    
    modifier AssetOwner(address ContractAddress, uint256 tokenId) {
        require(msg.sender == IERC721(ContractAddress).ownerOf(tokenId), "You are not an owner");
        _;
    }
}