// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {Test} from "forge-std/Test.sol";
import {Token} from "../src/tokens/Token.sol";

contract TokenTest is Test {
    Token internal token;
    address internal owner = vm.addr(0x1);
    address internal alice = vm.addr(0x2);
    address internal bob = vm.addr(0x3);

    function setUp() public {
        vm.prank(owner);
        token = new Token("Please", "PLS", 1000);
    }

    function testName() public {
        assertEq("Please", token.name());
    }

    function testSymbol() public {
        assertEq("PLS", token.symbol());
    }

    function testInitialSupply() public {
        assertEq(1000, token.totalSupply());
        assertEq(1000, token.balanceOf(owner));
    }

    function testTransfer() public {
        vm.prank(owner);
        token.transfer(alice, 100);
        assertEq(900, token.balanceOf(owner));
        assertEq(100, token.balanceOf(alice));
    }

    function testApproval() public {
        vm.prank(owner);
        token.approve(alice, 100);
        assertEq(100, token.allowance(owner, alice));
    }

    function testTransferFrom() public {
        vm.prank(owner);
        token.approve(alice, 100);

        vm.prank(alice);
        token.transferFrom(owner, bob, 100);
        assertEq(100, token.balanceOf(bob));
    }
}
