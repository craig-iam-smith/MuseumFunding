// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IX1155 {
  // define all the functions that we need from the 1155 token
  enum Status {
    Inactive,
    Active,
    Locked,
    Frozen,
    PaidOut
  }
  function safeTransferFrom(
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes calldata data
  ) external;
  function mint(
    address to,
    uint256 id,
    uint256 amount,
    bytes calldata data
  ) external;
  function balanceOf(address account, uint256 id) external view returns (uint256);
  function isApprovedForAll(address account, address operator)
    external
    view
    returns (bool);
  function setApprovalForAll(address operator, bool approved) external;
  function isMinter(address account) external view returns (bool);
  function setMinter(address account, bool minter) external;
  function setMaxPayout(uint256 _maxPayout) external;
  function maxPayout() external view returns (uint256);
  function totalSupply(uint256 id) external view returns (uint256);
  function uri(uint256 id) external view returns (string memory);
  function setURI(string memory newuri) external;
  function setMaxSupply(uint256 id, uint256 maxSupply) external;
  function maxSupply(uint256 id) external view returns (uint256);
  function getTotalTokens(uint256 id) external view returns (uint256);
  function getTokenOwners(uint256 id) external view returns (address [] memory) ;
  function setTokenStatus(uint256 id, uint256 status) external;
  function tokenStatus(uint256 id) external view returns (Status);
  function setTokenFee(uint256 id, uint256 fee) external;
  function tokenFee(uint256 id) external view returns (uint256);
  function setTokenFeeRecipient(uint256 id, address feeRecipient) external;
  function tokenFeeRecipient(uint256 id) external view returns (address);
  function setTokenMetadata(uint256 id, bytes memory data) external;
  function tokenMetadata(uint256 id) external view returns (bytes memory);
  function setTokenMetadataURI(uint256 id, string memory metadataURI) external;
  function tokenMetadataURI(uint256 id) external view returns (string memory);
  function xExtensions() external view returns (address);
       
}