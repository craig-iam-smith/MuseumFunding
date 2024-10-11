// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
// import OpenZeppelin ERC20 and AccessControl contracts

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./interface/IOracle.sol";
import "forge-std/console.sol";

// AssetPool is a contract that holds a pool of NFT assets, and mints ERC20 tokens against them.

// @title AssetPool
// @author Craig Smith
// @notice This contract is a simple asset pool that allows users to deposit NFTs and mint ERC20 tokens against them.

// @dev - AssetPool inherits from AccessControl and ERC1155Holder
// @dev - AssetPool is a contract that holds a pool of NFT assets, and mints ERC20 tokens against them.
contract AssetPool is AccessControl, IERC20, IERC1155, ERC1155Holder {
    // Define the roles
    // @dev todo push roles into a file to import
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    IERC20 public baseToken;
    IERC20 public assetPoolToken;
    IERC1155 public assetPoolNFT;
    IERC1155 public receiptNFT;
    IOracle public oracle;
    uint256 public requiredBaseTokenAmount;

    // mapping of token contract to id to amount
    mapping(IERC1155 => mapping(uint256 => uint256)) public nftBalances;
    mapping(IERC1155 => bool) public tokenContracts;
    mapping(address => mapping(uint256 => bool)) public tokenIds;
    // @dev - Define the name and symbol state variables

    // Define the events
    event AdminRoleGranted(address indexed account);
    event MinterRoleGranted(address indexed account);
    event AssetDeposited(address indexed account, IERC1155 indexed asset, uint256 id, uint256 amount);
    event AssetWithdrawn(address indexed account, IERC1155 indexed asset, uint256 id, uint256 amount);

    // Define the constructor
    // @param _baseToken - the token of the contract deployer, may require to use contract
    // @param _assetPoolToken - the token that will be minted against the NFTs
    // @param _assetPoolNFT - the NFT contract that assets are minted with
    // @param _receiptNFT - NFT minted to the user when they deposit assets
    // @dev - grant the DEFAULT_ADMIN_ROLE, ADMIN_ROLE, and MINTER_ROLE to the deployer
    constructor(
        IERC20 _baseToken,
        IERC20 _assetPoolToken,
        IERC1155 _assetPoolNFT,
        IERC1155 _receiptNFT,
        uint256 _requiredBaseTokenAmount
    ) {
        baseToken = _baseToken;
        assetPoolToken = _assetPoolToken;
        assetPoolNFT = _assetPoolNFT;
        receiptNFT = _receiptNFT;
        requiredBaseTokenAmount = _requiredBaseTokenAmount;

        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        grantRole(ADMIN_ROLE, _msgSender());
        grantRole(MINTER_ROLE, _msgSender());
    }
    // function - setBaseToken
    // @param - IERC20 _baseToken  (the token of the contract deployer, may require holding this token to access contract)
    function setBaseToken(IERC20 _baseToken) public onlyAdmin {
        baseToken = _baseToken;
    }
    // function - setAssetPoolToken
    // @param - IERC20 _assetPoolToken  (the token that will be minted against the NFTs)
    function setAssetPoolToken(IERC20 _assetPoolToken) public onlyAdmin {
        assetPoolToken = _assetPoolToken;
    }
    // function - setAssetPoolNFT
    // @param - IERC1155 _assetPoolNFT  (the NFT contract that assets are minted with)
    function setAssetPoolNFT(IERC1155 _assetPoolNFT) public onlyAdmin {
        assetPoolNFT = _assetPoolNFT;
    }
    // function - setReceiptNFT
    // @param - IERC1155 _receiptNFT  (NFT minted to the user when they deposit assets)
    function setReceiptNFT(IERC1155 _receiptNFT) public onlyAdmin {
        receiptNFT = _receiptNFT;
    }
    // function - setRequiredBaseTokenAmount
    // @param - uint256 _requiredBaseTokenAmount  (the amount of base token required to access the contract)
    function setRequiredBaseTokenAmount(
        uint256 _requiredBaseTokenAmount
    ) public onlyAdmin {
        requiredBaseTokenAmount = _requiredBaseTokenAmount;
    }
    // @dev - define receive function to accept ether
    receive() external payable {}
    // @dev - define fallback function to accept ether
    fallback() external payable {}

    // function - addAssetContract
    // @param - IERC1155 tokenContractAddress  (the address of the NFT contract to add to allowlist)
    // @param - uint256 tokenId  (the id of the NFT to add to allowlist)
    function addAssetContract(
        IERC1155 tokenContractAddress,
        uint256 tokenId
    ) public onlyAdmin {
        require(
            tokenContractAddress != IERC1155(address(0)),
            "AssetPool: token contract must not be 0"
        );
        require(
            tokenIds[address(tokenContractAddress)][tokenId] == false,
            "AssetPool: token contract already supported"
        );
        
        tokenContracts[tokenContractAddress] = true;
        tokenIds[address(tokenContractAddress)][tokenId] = true;
    }

    // @dev - todo move this to a library
    // @dev - Define the supportsInterface function
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC1155Holder, IERC165, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // Define the modifiers
    modifier onlyAdmin() {
        require(
            hasRole(ADMIN_ROLE, _msgSender()),
            "AssetPool: must have admin role to perform this action"
        );
        _;
    }
    modifier onlyMinter() {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "AssetPool: must have minter role to perform this action"
        );
        _;
    }
    modifier validToken(IERC1155 tokenContractAddress, uint256 tokenId) {
        require(
            tokenContracts[tokenContractAddress] == true,
            "AssetPool: token contract not supported"
        );
        require(
            tokenIds[address(tokenContractAddress)][tokenId] == true,
            "AssetPool: token id not supported"
        );
        _;
    }
    // function - depositAsset
    // @param - IERC1155 tokenContractAddress  (the address of the NFT contract to deposit)
    // @param - uint256 tokenId  (the id of the NFT to deposit)
    // @param - uint256 amount  (the amount of the NFT to deposit)
    function depositAsset(
        IERC1155 tokenContractAddress,
        uint256 tokenId,
        uint256 amount
    ) public validToken(tokenContractAddress, tokenId) {
        require(tokenContractAddress.balanceOf(msg.sender, tokenId) >= amount, "AssetPool: insufficient balance");

        nftBalances[tokenContractAddress][tokenId] += amount;
        tokenContractAddress.safeTransferFrom(
            msg.sender,
            address(this),
            tokenId,
            amount,
            ""
        );
        
        // @dev - emit event
        emit AssetDeposited(msg.sender, assetPoolNFT, tokenId, amount);

    }
    // function - withdrawAsset
    // @param - IERC1155 tokenContractAddress  (the address of the NFT contract to withdraw)
    // @param - uint256 tokenId  (the id of the NFT to withdraw)
    // @param - uint256 amount  (the amount of the NFT to withdraw)
    function withdrawAsset(
        IERC1155 tokenContractAddress,
        uint256 tokenId,
        uint256 amount
    ) public validToken(tokenContractAddress, tokenId) {
        // continuity balance check to prevent reentrancy attacks
        require(
            nftBalances[tokenContractAddress][tokenId] >= amount,
            "AssetPool: insufficient balance"
        );
        uint256 balance = tokenContractAddress.balanceOf(
            address(this),
            tokenId
        ) - amount;
        nftBalances[tokenContractAddress][tokenId] -= amount;
        assetPoolNFT.safeTransferFrom(
            address(this),
            msg.sender,
            tokenId,
            amount,
            ""
        );
        // this check prevents reentrancy attacks
        require(balance == tokenContractAddress.balanceOf(
            address(this),
            tokenId
        ), "AssetPool: balance mismatch");
        emit AssetWithdrawn(msg.sender, assetPoolNFT, tokenId, amount);
    }

//
    // Define the functions

    function totalSupply() external view override returns (uint256) {}

    function balanceOf(
        address account
    ) external view override returns (uint256) {}

    function transfer(
        address to,
        uint256 value
    ) external override returns (bool) {}

    function allowance(
        address owner,
        address spender
    ) external view override returns (uint256) {}

    function approve(
        address spender,
        uint256 value
    ) external override returns (bool) {}

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override returns (bool) {}

    function balanceOf(
        address account,
        uint256 id
    ) external view override returns (uint256) {}

    function balanceOfBatch(
        address[] calldata accounts,
        uint256[] calldata ids
    ) external view override returns (uint256[] memory) {}

    function setApprovalForAll(
        address operator,
        bool approved
    ) external override {}

    function isApprovedForAll(
        address account,
        address operator
    ) external view override returns (bool) {}

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external override {}

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external override {}

}
