// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol"; 
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "./interface/IX1155.sol";
import "./extensions/X1155Extensions.sol";

/// @dev - X1155 is an ERC1155 contract with additional functionality
/// @dev - X1155 is Ownable, ERC1155Burnable
/// @dev - X1155 keeps track of token owners and token ids
/// @dev - X1155 keeps track of total tokens minted
/// @dev - X1155 keeps track of token status (active, inactive, etc)
/// @dev - X1155 keeps track of transfer fee and fee recipient

abstract contract X1155 is ERC1155, Ownable, ERC1155Burnable, ERC1155URIStorage {
  X1155Extensions public xExtensions;
  uint256 public maxPayout = 1000000;
  constructor(address _xExtensionsAddr) ERC1155("") {
    xExtensions = X1155Extensions(_xExtensionsAddr);
    xExtensions.setMinter(msg.sender, true);
  }

  /*
//    @TODO - implement this
  function supportsInterface(bytes4 interfaceId) external view returns (bool) {
    // How should the check here be like?
  }
*/  
  /**
   * @dev Sets the URI for all token types.
   * @param newuri The new URI to set.
   * Requirements:
   * - Only the contract owner can call this function.
   */
  function setURI(uint256 id, string memory newuri) public onlyOwner {
    _setURI(id, newuri);
  }
  function uri(uint256 id) override(ERC1155, ERC1155URIStorage) public view returns (string memory) {
    return super.uri(id);
//   @dev todo - when adding json extension, use something like this
//    return string(abi.encodePacked(super.uri(id), ".json"));
  }

  function setStatus(IX1155.Status status, uint256 id) public onlyOwner {
    // xExtensions._status[id] = status;
    xExtensions.setStatus(id, status);
  }

  function tokenStatus(uint256 id) public view returns (IX1155.Status) {
    // return X1155Extensions._status[id];
    return xExtensions.getStatus(id);
  }
  
  function addMinter(address minter) public onlyOwner {
    // X1155Extensions._minters[minter] = true;
    xExtensions.setMinter(minter, true);

  }
  function removeMinter(address minter) public onlyOwner {
    // X1155Extensions._minters[minter] = false;
    xExtensions.setMinter(minter, false);
  }
  function getTokenOwners(uint256 id) external view returns (address [] memory) {
    // return X1155Extensions._tokenOwners[id];
    return xExtensions.getTokenOwners(id);
  }
  /**
   * @dev Mints a new token.
   * @param account The address to mint the token to.
   * @param id The ID of the token to mint.
   * @param amount The amount of tokens to mint.
   * @param data Additional data to pass to the receiver contract.
   * Requirements:
   * - Only the contract owner can call this function.
   */
  function mint(
    address account,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) public {
    // require (X1155Extensions._minters[msg.sender], "Only minters can mint");
    require (xExtensions.getMinter(msg.sender), "Only minters can mint");
    if (amount > 0) {
      // X1155Extensions._status[id] = IX1155.Status.Active;
      xExtensions.setStatus(id, IX1155.Status.Active);
    }
    _mint(account, id, amount, data);
  }

  /**
   * @dev Mints multiple new tokens.
   * @param to The address to mint the tokens to.
   * @param ids The IDs of the tokens to mint.
   * @param amounts The amounts of tokens to mint.
   * @param data Additional data to pass to the receiver contract.
   * Requirements:
   * - Only the contract owner can call this function.
   */
  function mintBatch(
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) public onlyOwner {
    uint256 idsLength = ids.length;
    require (idsLength > 0);
    for (uint256 i = 0; i < idsLength; i++) {
      if (amounts[i] > 0) {
        // X1155Extensions._status[ids[i]] = IX1155.Status.Active;
        xExtensions.setStatus(ids[i], IX1155.Status.Active);
      }
    }
    _mintBatch(to, ids, amounts, data);
  }

  /**
   * @dev Hook that is called before any token transfer or burning. This function keeps track of token owners and token ids.
   * @param from The address that currently owns the tokens.
   * @param to The address that will receive the tokens.
   * @param ids An array of token ids that are being transferred or burned.
   * @param values An array of amounts that are being transferred or burned.
   */
  
  function _update(
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory values
  ) internal override(ERC1155) {
    uint256 idsLength = ids.length;
    uint256 valuesLength = values.length;
    require(idsLength > 0);
    require(idsLength == valuesLength);
    uint256 id;
    uint256 amount;

    require(!xExtensions.isBlacklisted(to), "to is blacklisted");
    require(!xExtensions.isBlacklisted(from), "from is blacklisted");
    
    for (uint256 i = 0; i < idsLength; ) {
      id = ids[i];
      require(!xExtensions.isPaused(id), "ID is paused");
      
      amount = values[i];
      require(xExtensions.getStatus(id) == IX1155.Status.Active, "Token is not active");

      // minting, no fee
      if (from == address(0)) {
        // X1155Extensions._totalTokens[id] += amount;
        xExtensions.setTotalTokens(id, amount);
        // xExtensions.
        if ((balanceOf(to, id) == 0) && (amount > 0)){
          xExtensions.addToTracking(to, id);
        }
      }
      // burning, no fee
      else if (to == address(0)) {
        // X1155Extensions._totalTokens[id] -= amount;
        xExtensions.setTotalTokensDec(id, amount);
        if ((balanceOf(from, id) == amount) && (amount > 0)) {
          xExtensions.removeFromTracking(from, id);
        }
      }
      // transferring
      else {
        if ((balanceOf(from, id) == amount) && (amount > 0)) {
          xExtensions.removeFromTracking(from, id);
        }               
      // if 'to' does not have a _idTokenOwnerIndex (has no tokens)
        // if ((X1155Extensions._idTokenOwnerIndex[id][to] == 0) && (amount > 0)) {
        if ((xExtensions.getTokenOwnerIndex(id, to) == 0) && (amount > 0)) {
          xExtensions.addToTracking(to, id);
        }
      }
      unchecked {
        i++;
      }
    }
    super._update(from, to, ids, values);
  }

    /**
   * @dev Transfers ERC1155 tokens from one address to another.
   * @param from The address to transfer tokens from.
   * @param to The address to transfer tokens to.
   * @param id The ID of the token to transfer.
   * @param amount The amount of tokens to transfer.
   * @param data Optional data to include in the transfer.
   */
  function safeTransferFrom(
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes memory data
  ) public override {
    require(
      from == _msgSender() || isApprovedForAll(from, _msgSender()),
      "ERC1155: caller is not token owner or approved"
    );
    
    if (xExtensions.getTransferFee() == 0) {
      _safeTransferFrom(from, to, id, amount, data);
      return;
    }
    uint256 fee = (amount * xExtensions.getTransferFee()) / 10000;
    uint256 feeAmount = amount - fee;
    _safeTransferFrom(from, xExtensions.getFeeAddress(), id, fee, data);
    _safeTransferFrom(from, to, id, feeAmount, data);
  }

  /**
   * @dev Transfers multiple ERC1155 tokens from one address to another.
   * @param from The address to transfer tokens from.
   * @param to The address to transfer tokens to.
   * @param ids An array of token IDs to transfer.
   * @param amounts An array of token amounts to transfer.
   * @param data Optional data to include in the transfer.
   */
  function safeBatchTransferFrom(
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory amounts,
    bytes memory data
  ) public override {
    require(
      from == _msgSender() || isApprovedForAll(from, _msgSender()),
      "ERC1155: caller is not token owner or approved"
    );
    if (xExtensions.getTransferFee() == 0) {
      _safeBatchTransferFrom(from, to, ids, amounts, data);
      return;
    }
    uint256 fee;
    uint256[] memory fees = new uint256[](ids.length);
    for (uint256 i = 0; i < ids.length; ++i) {
      uint256 amount = amounts[i];
      fee = (amount * xExtensions.getTransferFee()) / 10000;
      amounts[i] = amount - fee;
      fees[i] = fee;
    }
    _safeBatchTransferFrom(from, xExtensions.getFeeAddress(), ids, fees, data);
    _safeBatchTransferFrom(from, to, ids, amounts, data);
  }
    
}