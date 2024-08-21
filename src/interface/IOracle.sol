// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

struct Asset {
    uint256 price;
    uint256 lastUpdate;
}

interface IOracle {
    function getPrice() external view returns (uint256);
    function setPrice(uint256 price) external;
    function getDecimals() external view returns (uint8);
}

interface IOracleAsset {
    function getPrice(uint256 id) external view returns (Asset memory);
    function setPrice(address _address, uint256 id, uint256 price) external;
    function getDecimals(uint256 id) external view returns (uint8);
}