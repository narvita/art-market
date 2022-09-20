// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract AssetMarket {
    address owner;
    struct Sale {
        uint256 tokenId;
        uint256 price;
        address contractAdress;
        address owner;
    }

    struct Bid {
        uint256 value;
        address bidderAddresses;
    }

    struct Auction {
        uint256 tokenId;
        uint256 price;
        address contractAdress;
        address owner;
        uint256 timeStamp;
        uint256 auctionDuration;
        Bid[] bid;
    }

    mapping (address => uint256[]) public userSalesIds;
    Sale[] shopSales;

    constructor() {
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


    function sale(address contAddr, uint256 tokenId, uint256 price) public  AssetOwner(contAddr, tokenId) {
        require(ERC721(contAddr).getApproved(tokenId) == address(this), "not appeoved");
        require(contAddr != address(0), "Address should not be 0");
        Sale memory newSale;
        newSale.tokenId = tokenId;
        newSale.price = price;
        newSale.contractAdress = contAddr;
        newSale.owner = msg.sender;

        shopSales.push(newSale);
        userSalesIds[msg.sender].push(shopSales.length - 1);
    }

    function createAuction (
        address contractaddress, 
        uint256 tokenId, 
        uint256 price, 
        uint256 auctionDuration) public AssetOwner (contractaddress, tokenId) {

        Auction memory newAuction;
        newAuction.tokenId = tokenId;
        newAuction.price = price;
        newAuction.contractAdress = contractaddress;
        newAuction.owner = msg.sender;
        newAuction.timeStamp = block.timestamp + auctionDuration;
        newAuction.auctionDuration = auctionDuration;
    }

    function saleById(uint256 id) view public returns (Sale memory) {
        return shopSales[id]; 
    }

    function saleByAddress(address user) view public returns( Sale[] memory) {
        uint arraylenght = shopSales.length;
        
        Sale[] memory _userSalesIds = new Sale[](arraylenght);

        for (uint i = 0; i < arraylenght; i++) {
            require(shopSales[i].owner == user, "You are not an owner");
            if (shopSales[i].owner == user) {
                _userSalesIds[i] = shopSales[i];
            }
            return _userSalesIds;
        }
    }

    function purchase(uint256 saleId) public payable {
        require(msg.value >= shopSales[saleId].price, "Value is not enugh");
        uint256 overPrice = msg.value - shopSales[saleId].price;
        ERC721(shopSales[saleId].contractAdress).approve(address(this), saleId);
        ERC721(shopSales[saleId].contractAdress).transferFrom(msg.sender, address(this), shopSales[saleId].tokenId); 

        if(overPrice > 0) {
            payable(msg.sender).transfer(overPrice);
        }   
    }
}