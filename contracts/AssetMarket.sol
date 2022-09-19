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

    function saleById(uint256 id) view public returns(uint256[] memory) {
        uint256[] memory userSalesById;

        for (uint256 i; i < userSales[id]; i++) {
            if(userSales[i] == id) {
                userSalesById.push(id);
            }
        }
        return userSalesById;
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
}