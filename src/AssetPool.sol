// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
// import OpenZeppelin ERC20 and AccessControl contracts

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
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
    uint256 public requiredBaseTokenAmount;

    // mapping of token contract to id to amount
    mapping(address => mapping(uint256 => uint256)) public nftBalances;
    mapping(address => IERC1155) public tokenContract;
    mapping(address => uint256) public tokenIds;
    // @dev - Define the name and symbol state variables

    // Define the events
    event AdminRoleGranted(address indexed account);
    event MinterRoleGranted(address indexed account);

    // Define the constructor
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

    function setBaseToken(IERC20 _baseToken) public onlyAdmin {
        baseToken = _baseToken;
    }

    function setAssetPoolToken(IERC20 _assetPoolToken) public onlyAdmin {
        assetPoolToken = _assetPoolToken;
    }

    function setAssetPoolNFT(IERC1155 _assetPoolNFT) public onlyAdmin {
        assetPoolNFT = _assetPoolNFT;
    }

    function setReceiptNFT(IERC1155 _receiptNFT) public onlyAdmin {
        receiptNFT = _receiptNFT;
    }

    function setRequiredBaseTokenAmount(
        uint256 _requiredBaseTokenAmount
    ) public onlyAdmin {
        requiredBaseTokenAmount = _requiredBaseTokenAmount;
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