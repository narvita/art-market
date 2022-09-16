// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract GyuliArt is ERC721 {
    address public owner;


    event InterfaceSupport(bytes4 interfaceId);
    event Aproove(address to, uint256 tokenId);
    event SafeTransferFrom(address from, address to, uint256 token, bytes data);
    event SafeTransferFrom(address from, address to, uint256 token);
    event SafeMint(address account, uint256 amount);


    constructor() ERC721("GyuliArt", "GA") {
        owner = msg.sender;
    }

    modifier OnlyOwner() {
        require(msg.sender == owner, "You are not owner the contract");
        _;
    }

    // function _burn(uint256 tokenId) internal override(ERC721) {
    //     super._burn(tokenId);
    // }

    // function BuyArt() public payable {

    // }

    function approve(address to, uint256 tokenId) public override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner nor approved for all"
        );
        emit Aproove( to,  tokenId);

        _approve(to, tokenId);
    }

    function safeMint(address to, uint256 tokenId, bytes memory data) internal {
        _safeMint(to, tokenId);
        emit SafeMint(to, tokenId);

    }

    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");
        emit Transfer(msg.sender, to, tokenId);
        _transfer(from, to, tokenId);
    }

     function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner nor approved");
        _safeTransfer(from, to, tokenId, data);
        emit SafeTransferFrom(from, to, tokenId, data);
    }

     function safeTransferFrom(address from, address to, uint256 tokenId) public override {
        safeTransferFrom(from, to, tokenId, "");
        emit SafeTransferFrom(from, to, tokenId);
    }
}
