// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IERC721.sol";

contract AssetMarket {
    address public owner;
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
        uint256 minBid;
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

    modifier OnlyAuctionOwner(uint256 acuctionId) {
        address auctionOwner = shopAuctions[acuctionId].owner;
        require(msg.sender == auctionOwner, "You are not an auction owner");
        _;
    }
    modifier AssetOwner(address contractAddress, uint256 tokenId) {
        require(msg.sender == IERC721(contractAddress).ownerOf(tokenId), "You are not an asset owner");
        _;
    }


    function sale(address contAddr, uint256 tokenId, uint256 price) public  AssetOwner(contAddr, tokenId) {
        require(IERC721(contAddr).getApproved(tokenId) == address(this), "not approved");
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
        uint256 minBid, 
        uint256 auctionDuration) public AssetOwner (contractaddress, tokenId) {

        require(IERC721(contractaddress).getApproved(tokenId) == address(this), "Market is not approved for the token");
        require(contractaddress != address(0), "Can't user zero address");
        require(minBid > 0, "Price should be more then 0");

        Auction memory newAuction;

        newAuction.tokenId = tokenId;
        newAuction.minBid = minBid;
        newAuction.contractAdress = contractaddress;
        newAuction.owner = msg.sender;
        newAuction.auctionDuration = auctionDuration;
        newAuction.timeStamp = block.timestamp + (auctionDuration * 1 days);

        shopAuctions.push(newAuction);
        IERC721(contractaddress).transferFrom(msg.sender, address(this), tokenId);
    }

    function bid(uint256 auctionId) public payable {
        require(auctionId < shopAuctions.length, "Auction does not exist");
        require(shopAuctions[auctionId].timeStamp > block.timestamp, "Auction already ended");
        require(msg.value > 0, "Sum cannot be 0");
        require(msg.sender != shopAuctions[auctionId].owner, "Owner cannot do bid");
        require(msg.sender != address(0), "Can't user zero address");
                
        Bid[] memory auctionArr = auctionBids[auctionId];

        bool exist = false;

        for (uint256 i = 0; i < auctionArr.length; i ++ ) {
            if(auctionArr[i].bidderAddress == msg.sender) {
                auctionBids[auctionId][i].value += msg.value;

                if (auctionBids[auctionId][i].value > shopAuctions[auctionId].minBid) {
                    shopAuctions[auctionId].minBid = auctionBids[auctionId][i].value;
                }

                exist = true;
            }
        }


        if(!exist){
            require(msg.value >= shopAuctions[auctionId].minBid, "Bid cannot be less then auction minBid");
            Bid memory newBid;
            newBid.value = msg.value;
            newBid.bidderAddress = msg.sender;
            shopAuctions[auctionId].minBid = msg.value;

            auctionBids[auctionId].push(newBid);
        }
    }


    function executeAuction(uint256 auctionId) public OnlyAuctionOwner(auctionId) {
        require(owner != address(0), "Can't zero address be zero");

        Bid[] memory bidArr = auctionBids[auctionId];
        
        uint256 maxBid = bidArr[0].value; 
        address winner = bidArr[0].bidderAddress;

        for (uint256 i = 1; i < bidArr.length; i++ ) {
            if(maxBid < bidArr[i].value) {

                payable(winner).transfer(maxBid);

                maxBid = bidArr[i].value;
                winner = bidArr[i].bidderAddress;
            } else {
                payable(bidArr[i].bidderAddress).transfer(bidArr[i].value);
            }
        }
        
        payable(shopAuctions[auctionId].owner).transfer(maxBid);
        IERC721(shopAuctions[auctionId].contractAdress).transferFrom(address(this), winner, shopAuctions[auctionId].tokenId); 
    }

    function highestBid(uint256 auctionId) view public returns(uint256) {
        return shopAuctions[auctionId].minBid;
    }

    function currentBid(uint256 auctionId) view public returns(uint256) {
        Bid[] memory bidArr = auctionBids[auctionId];
        
        for (uint256 i = 0; i < bidArr.length; i ++ ) {
            if(bidArr[i].bidderAddress == msg.sender) {
                return bidArr[i].value;
            }
        }
        return 0;
    }

    function cencelBid(uint256 auctionId)  public {
        Bid[] storage bidArr = auctionBids[auctionId]; 
        uint256 maxBid = bidArr[0].value; 
        bool maxBidOwner = false;

        for (uint256 i = 0; i < bidArr.length; i ++ ) {

            if(bidArr[i].bidderAddress == msg.sender) {

                if(shopAuctions[auctionId].minBid == bidArr[i].value) {
                    maxBidOwner = true;
                }
                payable(msg.sender).transfer(bidArr[i].value);
                bidArr[i] = bidArr[bidArr.length - 1];
                bidArr.pop();
                break ;

            } 

        }
        
        if(maxBidOwner) {
            for (uint256 j = 1; j < bidArr.length; j++ ) {
                if(maxBid < bidArr[j].value) {
                    maxBid = bidArr[j].value;
                } 
            }
            shopAuctions[auctionId].minBid = maxBid;

        }
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
        IERC721(shopSales[saleId].contractAdress).transferFrom(shopSales[saleId].owner, msg.sender, shopSales[saleId].tokenId); 

        if(overPrice > 0) {
            payable(msg.sender).transfer(overPrice);
        }  
    }
}