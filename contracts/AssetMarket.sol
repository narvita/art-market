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
        address bidderAddress;
    }

    struct Auction {
        uint256 tokenId;
        uint256 price;
        address contractAdress;
        address owner;
        uint256 auctionDuration;
        uint256 timeStamp;
    }

    mapping (address => uint256[]) userSalesIds;
    mapping (address => uint256[]) auctionIds;
    Sale[] shopSales;
    Auction[] shopAuctions;
    mapping (uint256 => Bid[]) auctionBids; 

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

    function auction (
        address contractaddress, 
        uint256 tokenId, 
        uint256 price, 
        uint256 auctionDuration) public AssetOwner (contractaddress, tokenId) {

        require(ERC721(contractaddress).getApproved(tokenId) == address(this), "Market is not approved for the token");
        require(contractaddress != address(0), "Can't user zero address");
        require(price > 0, "Price should be more then 0");

        Auction memory newAuction;

        newAuction.tokenId = tokenId;
        newAuction.price = price;
        newAuction.contractAdress = contractaddress;
        newAuction.owner = msg.sender;
        newAuction.auctionDuration = auctionDuration;
        newAuction.timeStamp = block.timestamp + (auctionDuration * 1 days);

        shopAuctions.push(newAuction);
        ERC721(contractaddress).transferFrom(msg.sender, address(this), newAuction.price);
    }

    function bid(uint256 auctionId) public payable {
        require(auctionId < shopAuctions.length, "Auction does not exist");
        require(shopAuctions[auctionId].timeStamp <= block.timestamp, "Auction already ended");
        require(msg.value > 0, "Sum cannot be 0");
        require(msg.sender != shopAuctions[auctionId].owner, "Owner cannot do bid");
        require(msg.value >= shopAuctions[auctionId].price, "Sum cannot be less then auction amount");

        if (msg.value > shopAuctions[auctionId].price) {
            shopAuctions[auctionId].price = msg.value;
        }

        Bid memory newBid;
        Bid[] memory auctionArr = auctionBids[auctionId];

        newBid.value = msg.value;
        newBid.bidderAddress = msg.sender;

        bool exist = false;

        for (uint256 i = 0; i < auctionArr.length; i ++ ) {
            if(auctionArr[i].bidderAddress == msg.sender) {
                auctionArr[i].value += msg.value;
                exist = true;
            }
        }
        if(exist){
            auctionBids[auctionId].push(newBid);
        }
    }


    function executeAuction(uint256 auctionId) public {
        Bid[] memory auctionArr = auctionBids[auctionId];
        uint256 maxBid = auctionArr[0].value; 
        address winner;

        for (uint256 i = 0; i < auctionArr.length; i++ ) {
            if(maxBid < auctionArr[i].value) {
                maxBid = auctionArr[i].value;
                winner = auctionArr[i].bidderAddress;
            }
            payable(auctionArr[i].bidderAddress).transfer(auctionArr[i].value);

        }

        ERC721(shopAuctions[auctionId].contractAdress).transferFrom(address(this), winner, maxBid);
            
    }

 
    function saleById(uint256 id) view public returns (Sale memory) {
        return shopSales[id]; 
    }


    function auctionById(uint256 id) view public returns (Auction memory) {
        return shopAuctions[id]; 
    }


    function auctionByAddress(address user) view public returns(Auction[] memory) {
        uint256 arraylenght = shopAuctions.length;

        uint256 size = 0;
        for (uint256 i = 0; i < arraylenght; i++) {
            if (shopAuctions[i].owner == user) {
                size++;
            }
        }

        Auction[] memory auctions = new Auction[](size);
        size = 0;

        for (uint256 i = 0; i < arraylenght; i++) {
            if (shopAuctions[i].owner == user) {
                auctions[size++] = shopAuctions[i];
            }
        }

        return auctions;
    }

    function saleByAddress(address user) view public returns(Sale[] memory) {
        uint256 arraylenght = shopSales.length;

         uint256 size = 0;
        for (uint256 i = 0; i < arraylenght; i++) {
            if (shopSales[i].owner == user) {
                size++;
            }
        }

        size = 0;
        Sale[] memory _userSales = new Sale[](arraylenght);

        for (uint256 i = 0; i < arraylenght; i++) {
            if (shopSales[i].owner == user) {
                _userSales[size++] = shopSales[i];
            }
        }

        return _userSales;
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