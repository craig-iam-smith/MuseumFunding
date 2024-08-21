// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "./interface/IOracle.sol";


contract Oracle {
    Asset public asset;  
    function getPrice() external view returns (Asset memory) {
        return asset;
    
    }
    // setPrice
    function setPrice(uint256 _price) external {
        asset.price = _price;
    }
    // getDecimals
    function getDecimals() external pure returns (uint8) {
        return 18;
    }
}

contract OracleAsset {
    mapping(uint => Asset) public asset;
    function setPrice(uint256 _id, uint256 _price) external {
        asset[_id] = Asset(_price, block.timestamp);
    }
    function getPrice(uint256 _id) external view returns (Asset memory) {
        return asset[_id];
    }
    function getDecimals(uint256 _id) external pure returns (uint8) {
        return 18;
    }
}