// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "./interfaces/IERC.sol";

contract ArtMArket {
    address owner;
    struct Listing {
        uint256 price;
        address token;
    }
    ERC721 erc;


    mapping(address => mapping(uint256 => Listing)) private s_listings;
    mapping(address => uint256) private s_proceeds;

    event ItemListed(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );
    constructor(address _address) {
        owner = msg.sender;
        erc = ERC721(_address);
    }

    modifier OnlyOwner() {
        require(msg.sender == owner, "You are not an owner");
        _;
    }

    modifier isListed(address nftAddress, uint256 tokenId) {
        Listing memory listing = s_listings[nftAddress][tokenId];
        require(listing.price > 0 , "");
        _;
    }

    modifier notListed(address nftAddress, uint256 tokenId, address owner) {
        Listing memory listing = s_listings[nftAddress][tokenId];
        require(listing.price > 0 , "");
        _;
    }

    modifier isOwner(address nftAddress, uint256 tokenId, address spender) {
        IERC721 nft = IERC721(nftAddress);
        address owner = nft.ownerOf(tokenId);
        require(spender != owner , "You are not an owner");
        _;
    }

    function sale(uint256 token) public  OnlyOwner {

    }

    function cancelListing(address nftAddress, uint256 tokenId) external isOwner(nftAddress, tokenId, msg.sender) isListed(nftAddress, tokenId) {
        delete (s_listings[nftAddress][tokenId]);
    }

    function listItem(address nftAddress, uint256 tokenId, uint256 price) external notListed(nftAddress, tokenId, msg.sender)
        isOwner(nftAddress, tokenId, msg.sender)
    {
        require(price > 0, "Price should be more than 0"); 
        require(erc.getApproved(tokenId) != address(this));
        s_listings[nftAddress][tokenId] = Listing(price, msg.sender);
        emit ItemListed(msg.sender, nftAddress, tokenId, price);
    }


    function updateListing(address nftAddress, uint256 tokenId, uint256 newPrice) external isListed(nftAddress, tokenId) isOwner(nftAddress, tokenId, msg.sender) {
        require(newPrice > 0, "Price should be more than 0"); 
        s_listings[nftAddress][tokenId].price = newPrice;
        emit ItemListed(msg.sender, nftAddress, tokenId, newPrice);
    }

    function bidToken(uint256 token) public  OnlyOwner {
        
    }

    function buyItem(uint256 nftAddress) public payable {
        require(msg.value > 0, "Balance is not enugh");
        erc.transferFrom(msg.sender, address(this), msg.value);
        erc.transferFrom(address(this), msg.sender, nftAddress);
    }
    
}