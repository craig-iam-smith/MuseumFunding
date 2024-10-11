// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/AssetPool.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("Mock Token", "MTK") {}
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract MockERC1155 is ERC1155 {
    constructor() ERC1155("") {}
    function mint(address to, uint256 id, uint256 amount) public {
        _mint(to, id, amount, "");
    }
}

contract AssetPoolTest is Test {
    AssetPool public assetPool;
    MockERC20 public baseToken;
    MockERC20 public assetPoolToken;
    MockERC1155 public assetPoolNFT;
    MockERC1155 public receiptNFT;
    address public admin;
    address public user;

    uint256 constant REQUIRED_BASE_TOKEN_AMOUNT = 100;

    function setUp() public {
        admin = address(this);
        user = address(0x1);
        
        baseToken = new MockERC20();
        assetPoolToken = new MockERC20();
        assetPoolNFT = new MockERC1155();
        receiptNFT = new MockERC1155();

        assetPool = new AssetPool(
            IERC20(address(baseToken)),
            IERC20(address(assetPoolToken)),
            IERC1155(address(assetPoolNFT)),
            IERC1155(address(receiptNFT)),
            REQUIRED_BASE_TOKEN_AMOUNT
        );
    }

    function testConstructor() public view {
        assertEq(address(assetPool.baseToken()), address(baseToken));
        assertEq(address(assetPool.assetPoolToken()), address(assetPoolToken));
        assertEq(address(assetPool.assetPoolNFT()), address(assetPoolNFT));
        assertEq(address(assetPool.receiptNFT()), address(receiptNFT));
        assertEq(assetPool.requiredBaseTokenAmount(), REQUIRED_BASE_TOKEN_AMOUNT);
        assertTrue(assetPool.hasRole(assetPool.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(assetPool.hasRole(assetPool.ADMIN_ROLE(), admin));
        assertTrue(assetPool.hasRole(assetPool.MINTER_ROLE(), admin));
    }

    function testSetBaseToken() public {
        MockERC20 newBaseToken = new MockERC20();
        assetPool.setBaseToken(IERC20(address(newBaseToken)));
        assertEq(address(assetPool.baseToken()), address(newBaseToken));
    }

    function testSetBaseTokenFailsForNonAdmin() public {
        MockERC20 newBaseToken = new MockERC20();
        vm.prank(user);
        vm.expectRevert("AssetPool: must have admin role to perform this action");
        assetPool.setBaseToken(IERC20(address(newBaseToken)));
    }

    function testAddAssetContract() public {
        uint256 tokenId = 1;
        assetPool.addAssetContract(IERC1155(address(assetPoolNFT)), tokenId);
        assertTrue(assetPool.tokenContracts(IERC1155(address(assetPoolNFT))));
        assertTrue(assetPool.tokenIds(address(assetPoolNFT), tokenId));
    }

    function testAddAssetContractFailsForNonAdmin() public {
        uint256 tokenId = 1;
        vm.prank(user);
        vm.expectRevert("AssetPool: must have admin role to perform this action");
        assetPool.addAssetContract(IERC1155(address(assetPoolNFT)), tokenId);
    }

    function testDepositAsset() public {
        uint256 tokenId = 1;
        uint256 amount = 10;
        
        assetPool.addAssetContract(IERC1155(address(assetPoolNFT)), tokenId);
        assetPoolNFT.mint(user, tokenId, amount);
        
        vm.startPrank(user);
        assetPoolNFT.setApprovalForAll(address(assetPool), true);
        assetPool.depositAsset(IERC1155(address(assetPoolNFT)), tokenId, amount);
        vm.stopPrank();

        assertEq(assetPool.nftBalances(IERC1155(address(assetPoolNFT)), tokenId), amount);
        assertEq(assetPoolNFT.balanceOf(address(assetPool), tokenId), amount);
    }

    function testWithdrawAsset() public {
        uint256 tokenId = 1;
        uint256 amount = 10;
        
        assetPool.addAssetContract(IERC1155(address(assetPoolNFT)), tokenId);
        assetPoolNFT.mint(user, tokenId, amount);
        
        vm.startPrank(user);
        assetPoolNFT.setApprovalForAll(address(assetPool), true);
        assetPool.depositAsset(IERC1155(address(assetPoolNFT)), tokenId, amount);
        assetPool.withdrawAsset(IERC1155(address(assetPoolNFT)), tokenId, amount);
        vm.stopPrank();

        assertEq(assetPool.nftBalances(IERC1155(address(assetPoolNFT)), tokenId), 0);
        assertEq(assetPoolNFT.balanceOf(address(user), tokenId), amount);
    }

    function testWithdrawAssetFailsForInsufficientBalance() public {
        uint256 tokenId = 1;
        uint256 amount = 10;
        
        assetPool.addAssetContract(IERC1155(address(assetPoolNFT)), tokenId);
        assetPoolNFT.mint(user, tokenId, amount);
        
        vm.startPrank(user);
        assetPoolNFT.setApprovalForAll(address(assetPool), true);
        assetPool.depositAsset(IERC1155(address(assetPoolNFT)), tokenId, amount);
        vm.expectRevert("AssetPool: insufficient balance");
        assetPool.withdrawAsset(IERC1155(address(assetPoolNFT)), tokenId, amount + 1);
        vm.stopPrank();
    }
}

