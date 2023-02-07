// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {Test} from "forge-std/Test.sol";
import {VotingToken} from "../src/tokens/VotingToken.sol";

contract TokenTest is Test {
    VotingToken internal votingToken;
    address internal owner = vm.addr(0x1);
    address internal alice = vm.addr(0x2);
    address internal bob = vm.addr(0x3);

    function setUp() public {
        vm.prank(owner);
        votingToken = new VotingToken(1000);
    }

    function testName() public {
        assertEq("VotingToken", votingToken.name());
    }

    function testSymbol() public {
        assertEq("VTK", votingToken.symbol());
    }

    function testInitialSupply() public {
        assertEq(1000, votingToken.totalSupply());
    }

    function testMintOwner() public {
        vm.prank(owner);
        votingToken.mint(1000);
        assertEq(2000, votingToken.totalSupply());
    }

    function testMintNonOwner() public {
        vm.prank(alice);
        vm.expectRevert("Ownable: caller is not the owner");
        votingToken.mint(1000);
    }

    function testDelegate() public {
        vm.prank(owner);
        votingToken.delegate(alice);
        assertEq(alice, votingToken.delegates(owner));
    }
}
