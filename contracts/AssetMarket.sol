// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract AssetMarket is ERC721{
    address owner;
    struct Sale {
        uint256 tokenId;
        uint256 price;
        address contractAdress;
    }

    mapping (address => uint256) private contractAdress;
    mapping (address => Sale[]) private sales;

    constructor() ERC721("Asset", "AS") {
        owner = msg.sender; 
    }

    modifier OnlyOwner() {
        require(msg.sender == owner, "You are not an owner");
        _;
    }

    
    modifier AssetOwner(address contractAddress, uint256 tokenId) {
        require(msg.sender == IERC721(contractAddress).ownerOf(tokenId), "You are not an owner");
        _;
    }


    function sale(address contAddr, uint256 tokenId, uint256 price) public AssetOwner(contAddr, tokenId) {
        Sale memory newSale;
        newSale.tokenId = tokenId;
        newSale.price = price;
        newSale.contractAdress = contAddr;
        sales[msg.sender].push(newSale);
    }
}