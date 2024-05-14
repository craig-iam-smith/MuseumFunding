// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {BaseToken} from "../src/BaseToken.sol";
import "forge-std/console.sol";

contract CounterTest is Test {
    BaseToken public platformToken;
    address public alice = makeAddr("alice");

    function setUp() public {
        platformToken = new BaseToken("Platform Token", "PTK");
    }

    function test_decimals() public view{
        uint decimals = platformToken.decimals();
        assertEq(decimals, 18);
    }

    function test_mint () public {
        uint x = 100;
        platformToken.mint(alice, x);
        assertEq(platformToken.balanceOf(alice), x);
        platformToken.grantRole(platformToken.MINTER_ROLE(), alice);
        uint y = 200;
        platformToken.mint(alice, y);
        assertEq(platformToken.balanceOf(alice), x + y);
    }
    function testFail_mint1 () public {
        uint y = 200;
        vm.prank(alice);
        platformToken.mint(alice, y);
    }
    function test_burn () public {
        uint y = 200;
        platformToken.mint(alice, y);
        assertEq(platformToken.balanceOf(alice), y);
        uint z = 100;
        platformToken.burn(alice, z);
        assertEq(platformToken.balanceOf(alice), y-z);
        platformToken.grantRole(platformToken.MINTER_ROLE(), alice);
        uint w = 50;
        platformToken.burn(alice, w);
        assertEq(platformToken.balanceOf(alice), y-z-w);
    }
    function testFail_burn1 () public {
        uint z = 100;
        platformToken.mint(alice, z);
        vm.prank(alice);
        platformToken.burn(alice, z);
        assertEq(platformToken.balanceOf(alice), 0);
    }

}
