// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract AssetMarket is ERC721{
    address owner;
    struct Sale {
        uint256 tokenId;
        uint256 price;
        address contractAdress;
        address owner;
    }

    mapping (address => uint256[]) public userSales;
    Sale[] shopSales;

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
        newSale.owner = msg.sender;

        shopSales.push(newSale);
        userSales[msg.sender].push(shopSales.length - 1);
    }

    function saleById(uint256 id) view public returns(uint256 memory) {
        return userSales[id];
    }

    function saleByAddress(address user) view public returns( Sale[] memory) {
        Sale memory userSales;
        
        for (uint256 i; i < Sale.lenght; i ++) {
            if (Sale[i][owner] == user) {
                userSales.push(Sale[i]);
            }
        }
        return userSales;
    }

    function purchase(uint256 tokenId) public payable {
        require(msg.value == Sale[tokenId].price, "Value is not enugh");
        if (msg.value == Sale[tokenId].price) {
            ERC721.transferFrom(msg.sender, address(this), msg.value);
        } else if (msg.value > Sale[tokenId].price) {
            uint256 overload = Sale[tokenId].price - msg.value;
            ERC721.Transfer(msg.sender, address(this), Sale[tokenId].price - overload);
            ERC721.Transfer(msg.sender, overload);

        }
        
    }
}