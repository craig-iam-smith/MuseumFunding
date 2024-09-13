// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {X1155} from "../src/X1155.sol";
import {X1155Extensions} from "../src/extensions/X1155Extensions.sol";
import "forge-std/console.sol";

contract X1155Test is Test {
    X1155Extensions public xExtensionsAddr = new X1155Extensions();
    X1155 public x1155;

    function setUp() public {

        x1155 = new X1155(address(xExtensionsAddr));
    }
    function test_mint() public {
        address alice = makeAddr("alice");
        x1155.mint(alice, 1, 1, "");
        assertEq(x1155.balanceOf(alice, 1), 1);
    }
    // vm.prank(alice) should fail because alice is not minter
    function testFail_mint() public {
        address alice = makeAddr("alice");
        vm.prank(alice);
        x1155.mint(alice, 1, 1, "");
        assertEq(x1155.balanceOf(alice, 1), 1);
    }
    function test_mint_batch() public {
        address alice = makeAddr("alice");
        uint256[] memory ids = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);
        ids[0] = 1;
        amounts[0] = 1;
        ids[1] = 2;
        amounts[1] = 2;
        x1155.mintBatch(alice, ids, amounts, "");
        assertEq(x1155.balanceOf(alice, 1), 1);
        assertEq(x1155.balanceOf(alice, 2), 2);
    }
    function testFail_mint_batch() public {
        address alice = makeAddr("alice");
        uint256[] memory ids = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);
        ids[0] = 1;
        amounts[0] = 3;
        ids[1] = 2;
        amounts[1] = 4;
        vm.prank(alice);
        x1155.mintBatch(alice, ids, amounts, "");
        // alice should not be able to mint
        assertEq(x1155.balanceOf(alice, 1), 1);
        assertEq(x1155.balanceOf(alice, 2), 2);
    }
    function test_safeTransferFrom() public {
        address alice = makeAddr("alice");
        address bob = makeAddr("bob");
        x1155.mint(alice, 1, 1, "");
        vm.prank(alice);
        x1155.safeTransferFrom(alice, bob, 1, 1, "");
        assertEq(x1155.balanceOf(bob, 1), 1);
        assertEq(x1155.balanceOf(alice, 1), 0);
    }
    function testFail_safeTransferFrom() public {
        address alice = makeAddr("alice");
        address bob = makeAddr("bob");
        x1155.mint(alice, 1, 1, "");
        assertEq(x1155.balanceOf(bob, 1), 0);
        assertEq(x1155.balanceOf(alice, 1), 1);
        vm.prank(bob);
        x1155.safeTransferFrom(alice, bob, 1, 1, "");
        assertEq(x1155.balanceOf(bob, 1), 0);
        assertEq(x1155.balanceOf(alice, 1), 1);
    }
    function test_safeTransferFrom_batch() public {
        address alice = makeAddr("alice");
        address bob = makeAddr("bob");
        uint256[] memory ids = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);
        ids[0] = 1;
        amounts[0] = 1;
        ids[1] = 2;
        amounts[1] = 2;
        x1155.mintBatch(alice, ids, amounts, "");
        vm.prank(alice);
        x1155.safeBatchTransferFrom(alice, bob, ids, amounts, "");
        assertEq(x1155.balanceOf(bob, 1), 1);
        assertEq(x1155.balanceOf(bob, 2), 2);
        assertEq(x1155.balanceOf(alice, 1), 0);
        assertEq(x1155.balanceOf(alice, 2), 0);
    }
    function testFail_safeTransferFrom_batch() public {
        address alice = makeAddr("alice");
        address bob = makeAddr("bob");
        uint256[] memory ids = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);
        ids[0] = 1;
        amounts[0] = 1;
        ids[1] = 2;
        amounts[1] = 2;
        x1155.mintBatch(alice, ids, amounts, "");
        vm.prank(bob);
        x1155.safeBatchTransferFrom(alice, bob, ids, amounts, "");
        assertEq(x1155.balanceOf(bob, 1), 0);
        assertEq(x1155.balanceOf(bob, 2), 0);
        assertEq(x1155.balanceOf(alice, 1), 1);
        assertEq(x1155.balanceOf(alice, 2), 2);
    }
}
