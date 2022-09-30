// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721 {
  function ownerOf(uint256 _tokenId) external  returns (address _owner);
  function exists(uint256 _tokenId) external returns (bool _exists);
  function approve(address _to, uint256 _tokenId) external;
  function getApproved(uint256 _tokenId) external returns (address _operator);
  function setApprovalForAll(address _operator, bool _approved) external;
  function isApprovedForAll(address _owner, address _operator) external returns (bool);
  function transferFrom(address _from, address _to, uint256 _tokenId) external;
  function safeTransferFrom(address _from, address _to, uint256 _tokenId) external;
}
