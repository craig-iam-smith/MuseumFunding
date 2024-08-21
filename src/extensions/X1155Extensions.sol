// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Blacklistable.sol";
import "./PausableID.sol";
import "../interface/IX1155.sol";

 abstract contract X1155Extensions  is Blacklistable, PauseableID{
    event FeeAddressSet(address indexed _feeAddress); 
    event TransferFeeSet(uint256 indexed _transferFee);
    /// @notice Mapping from owner to array of token IDs owned
    mapping(address => uint256[]) internal _ownedTokens;
    /// @notice Mapping from token ID to array of owners
    mapping(uint256 => address[]) internal _tokenOwners;
    mapping(uint256 => mapping(address => uint256)) internal _idTokenOwnerIndex;
    /// @notice Mapping from token ID to total tokens minted
    mapping(uint256 => uint256) internal _totalTokens;
    /// @dev Transfer fee in basis points (1/100th of a percent)
    uint256 internal TransferFee = 0;
    mapping(address => bool) internal _minters;
    /// @dev Fee recipient address
    /// @dev default to dummy address for testing
    address internal FeeAddress = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    mapping(uint256 => IX1155.Status) internal _status;
    // State variables related to extensions
    uint256 public extensionVariable;

    // Events related to extensions
    event ExtensionEvent(uint256 indexed value);

    /**
     * @return the transfer fee
     */
    function getTransferFee() external view returns (uint256) {
        return TransferFee;        
    }

    /**
     * @return the fee address
     */
    function getFeeAddress() external view returns (address) {
        return FeeAddress;        
    }

    /**
     * @dev This function allows the minters mapping to be accesed by X1155 contract.
     * @param minter The address of the minter.
     * @param isMinter The boolean determining if the address is in the mapping.
     */
    function setMinter(address minter, bool isMinter) external {
        _minters[minter] = isMinter;
    }

    /**
     * @dev This function allows the minters mapping to be accesed by X1155 contract.
     * @param minter The address of the minter.
     */
    function getMinter(address minter) external view returns (bool) {
        return _minters[minter];
    }

    /**
     * @dev This function allows the minters mapping to be accesed by X1155 contract.
     * @param id the id
     * @param stat the stat
     */
    function setStatus(uint256 id, IX1155.Status stat) external {
        _status[id] = stat;
    }

    /**
     * @dev This function allows the minters mapping to be accesed by X1155 contract.
     * @param id the id
     */
    function getStatus(uint256 id) external view returns (IX1155.Status) {
        return _status[id];
    }

    // mapping(uint256 => address[]) public _tokenOwners;
    /**
     * @dev This function allows the minters mapping to be accesed by X1155 contract.
     * @param id the id
     * @param addrs Addresses of token holders
     */
    function setTokenOwners(uint256 id, address[] memory addrs) external {
        _tokenOwners[id] = addrs;
    }

    /**
     * @dev This function allows the minters mapping to be accesed by X1155 contract.
     * @param id the id
     */
    function getTokenOwners(uint256 id) external view returns (address[] memory) {
        return _tokenOwners[id];
    }

    /**
     * @dev Setter function to set the index for a specific id and owner
     * @param id the id
     * @param owner the token owner
     * @param index the index
     */
    function setTokenOwnerIndex(uint256 id, address owner, uint256 index) external {
        _idTokenOwnerIndex[id][owner] = index;
    }

    // Getter function to retrieve the index for a specific id and owner
    function getTokenOwnerIndex(uint256 id, address owner) external view returns (uint256) {
        return _idTokenOwnerIndex[id][owner];
    }

    // Functions related to extensions
    function setExtensionVariable(uint256 _value) external onlyOwner {
        extensionVariable = _value;
        emit ExtensionEvent(_value);
    }

    /**
     * @dev Removes a token from the tracking arrays of a specific account.
     * @param id The ID of the token to remove.
     * @param account The address of the account to remove the token from.
     */
    function removeFromTracking(address account, uint256 id) public {

        uint256 ownersLength = _tokenOwners[id].length-1;
        uint256 tokensLength = _ownedTokens[account].length-1;
        uint256 index = _idTokenOwnerIndex[id][account];  
        // if balanceOf(account, id) == amount delete from arrays
        if (index != ownersLength) {
            _tokenOwners[id][index] = _tokenOwners[id][ownersLength];
        }
        uint256 i;
        for (i = 0; i < tokensLength; ) {
        if (_ownedTokens[account][i] == id) {
            _ownedTokens[account][i] = _ownedTokens[account][tokensLength];
            break;
        }
        unchecked {
            i++;
        }
        }
        _ownedTokens[account].pop();
        _tokenOwners[id].pop();
        _idTokenOwnerIndex[id][account] = 0;
    }

    /**
     * @dev addToTracking is used to add a token to the tracking arrays of a specific account.
     * @param id The id of the token to add.
     * @param account The address of the account to add the token to.
     */
    function addToTracking (address account, uint256 id) public {
        require (account != address(0));
        _ownedTokens[account].push(id); 
        _tokenOwners[id].push(account);     
        _idTokenOwnerIndex[id][account] = _tokenOwners[id].length-1; // keep track of index    
    }

    /**
     * @dev Returns the total number of tokens with a given ID.
     * @param id The ID of the token to get the total number of.
     * @return The total number of tokens with the given ID.
     */
    function getTotalTokens(uint256 id) public view returns (uint256) {
        return _totalTokens[id];
    }

    // mapping(uint256 => uint256) public _totalTokens;
    /**
     * @dev This function allows the minters mapping to be accesed by X1155 contract.
     * @param id the id
     * @param amount uint256 of tokens
     */
    function setTotalTokens(uint256 id, uint256 amount) external {
        _totalTokens[id] += amount;
    }

    /**
     * @dev This function allows the minters mapping to be accesed by X1155 contract.
     * @param id the id
     * @param amount uint256 of tokens to be subtracted
     */
    function setTotalTokensDec(uint256 id, uint256 amount) external {
        _totalTokens[id] -= amount;
    }

    /**
     * @dev getTokensOwned
     * @param account owner address of NFT
     * @return returns array of token ids owned by this address
     */
    function getTokensOwned(
        address account
    ) public view returns (uint256[] memory) {
        require(account != address(0));
        return _ownedTokens[account];
    }

    /**
     * @dev getOwnersOfToken
     * @param tokenId token id of nft
     * @return returns array of owner addresses of this tokenid
     */
    function getOwnersOfToken(
        uint256 tokenId
    ) public view returns (address[] memory) {
        return _tokenOwners[tokenId];
    }

    /**
     * @dev Sets the transfer fee for the contract.
     * @dev - TransferFee is a percentage of the transfer amount that is sent to the FeeAddress
     * @dev - TransferFee is set in basis points (1/100th of a percent)
     * @dev - TransferFee is set to 0 by default
     * @param _fee The transfer fee in basis points (1/100th of a percent).
     */
    function setTransferFee(uint256 _fee) public onlyOwner {
        emit TransferFeeSet(TransferFee);
        require(_fee < 1000, "Fee must be less than 10%");
        TransferFee = _fee;
    } 

    /**
     * @dev Sets the address to receive fees.
     * @param _address The address to receive fees.
     */
    function setFeeAddress(address _address) public onlyOwner {
        emit FeeAddressSet(FeeAddress);
        require(_address != address(0));
        FeeAddress = _address;
    }

}
