// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {rwAsset} from "../src/rwAsset.sol";
import "forge-std/console.sol";

contract CounterTest is Test {
    rwAsset public AssetToken;
    address public alice = makeAddr("alice");

    function setUp() public {
        AssetToken = new rwAsset();
    }

    function test_mint () public {
        uint x = 100;
        AssetToken.mint(alice, 1, x, "");
        assertEq(AssetToken.balanceOf(alice, 1), x);
        AssetToken.grantRole(AssetToken.MINTER_ROLE(), alice);
        uint y = 200;
        AssetToken.mint(alice, 1, y, "");
        assertEq(AssetToken.balanceOf(alice, 1), x + y);
    }
    function testFail_mint1 () public {
        uint y = 200;
        vm.prank(alice);
        AssetToken.mint(alice, 1, y, "");
    }
    function test_burn () public {
        uint y = 200;
        AssetToken.mint(alice, 1, y, "");
        assertEq(AssetToken.balanceOf(alice, 1), y);
        uint z = 100;
        AssetToken.burn(alice, 1, z);
        assertEq(AssetToken.balanceOf(alice, 1), y-z);
        AssetToken.grantRole(AssetToken.MINTER_ROLE(), alice);
        uint w = 50;
        AssetToken.burn(alice, 1, w);
        assertEq(AssetToken.balanceOf(alice, 1), y-z-w);
    }
    function testFail_burn1 () public {
        uint z = 100;
        AssetToken.mint(alice, 1, z, "");
        vm.prank(alice);
        AssetToken.burn(alice, 1, z);
        assertEq(AssetToken.balanceOf(alice, 1), 0);
    }
}
