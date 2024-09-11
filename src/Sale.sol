// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./interface/IX1155.sol";

contract MuseumCollection is Ownable, ReentrancyGuard {
    uint256 public constant AUTOMOBILE = 0;
    uint256 public price = 0.1 ether;
    uint256 public maxSupply = 100000;
    uint256 public totalSupply = 0;
    IX1155[] public x1155;
    string public museum;

    constructor(string memory _museum) Ownable(msg.sender) {
        museum = _museum;
    }

    function setURI(string memory newuri) public onlyOwner {
        x1155[0].setURI(newuri);
    }

    function setPrice(uint256 newPrice) public onlyOwner {
        price = newPrice;
    }

    function mint() public payable nonReentrant {
        require(msg.value >= price, "Insufficient payment");
        require(totalSupply < maxSupply, "Max supply reached");

        x1155[0].mint(msg.sender, AUTOMOBILE, 1, "");
        totalSupply++;

        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }
}
