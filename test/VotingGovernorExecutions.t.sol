// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "./console.sol";
import {VotingGovernor} from "../src/VotingGovernor.sol";
import {BaseVotingGovernorTest} from "./BaseVotingGovernor.t.sol";

contract VotingGovernorExecutionsTest is BaseVotingGovernorTest {
    function testProposalQueue() public {
        vm.startPrank(owner);
        votingToken.delegate(owner);
        vm.roll(block.number + 1);

        uint256 proposalId = _propose();
        assertEq(0, uint256(votingGovernor.state(proposalId)));

        vm.roll(block.number + votingGovernor.votingDelay() + 1);
        assertEq(1, uint256(votingGovernor.state(proposalId)));

        votingGovernor.castVote(proposalId, 1);

        vm.roll(block.number + votingGovernor.votingPeriod() + 1);
        assertEq(4, uint256(votingGovernor.state(proposalId)));

        votingGovernor.queue(proposalId);
        assertEq(5, uint256(votingGovernor.state(proposalId)));
        vm.stopPrank();
    }

    function testDefeatedProposalQueue() public {
        vm.startPrank(owner);
        votingToken.delegate(owner);
        vm.roll(block.number + 1);

        uint256 proposalId = _propose();
        assertEq(0, uint256(votingGovernor.state(proposalId)));

        vm.roll(block.number + votingGovernor.votingDelay() + 1);
        assertEq(1, uint256(votingGovernor.state(proposalId)));

        vm.roll(block.number + votingGovernor.votingPeriod() + 1);
        assertEq(3, uint256(votingGovernor.state(proposalId)));

        vm.expectRevert("Governor: proposal not successful");
        votingGovernor.queue(proposalId);
        vm.stopPrank();
    }

    function testProposalExecutionSuccess() public {
        vm.startPrank(owner);
        votingToken.delegate(owner);
        vm.roll(block.number + 1);

        uint256 proposalId = _propose();
        assertEq(0, uint256(votingGovernor.state(proposalId)));

        vm.roll(block.number + votingGovernor.votingDelay() + 1);
        assertEq(1, uint256(votingGovernor.state(proposalId)));

        votingGovernor.castVote(proposalId, 1);

        vm.roll(block.number + votingGovernor.votingPeriod() + 1);
        assertEq(4, uint256(votingGovernor.state(proposalId)));

        votingGovernor.queue(proposalId);
        assertEq(5, uint256(votingGovernor.state(proposalId)));
        vm.stopPrank();

        vm.prank(executor);
        vm.warp(block.timestamp + 10000000000);
        votingGovernor.execute(proposalId);
    }

    function testProposalExecutionEffects() public {
        vm.startPrank(owner);
        votingToken.delegate(owner);
        vm.roll(block.number + 1);

        uint256 proposalId = _propose();
        assertEq(0, uint256(votingGovernor.state(proposalId)));

        vm.roll(block.number + votingGovernor.votingDelay() + 1);
        assertEq(1, uint256(votingGovernor.state(proposalId)));

        votingGovernor.castVote(proposalId, 1);

        vm.roll(block.number + votingGovernor.votingPeriod() + 1);
        assertEq(4, uint256(votingGovernor.state(proposalId)));

        votingGovernor.queue(proposalId);
        assertEq(5, uint256(votingGovernor.state(proposalId)));
        vm.stopPrank();

        vm.prank(executor);
        vm.warp(block.timestamp + 10000000000);
        votingGovernor.execute(proposalId);

        assertEq(100, usdc.balanceOf(noone));
        assertEq(900, usdc.balanceOf(address(timelockController)));
    }

    function testProposalExecutionTimelockNotReady() public {
        vm.startPrank(owner);
        votingToken.delegate(owner);
        vm.roll(block.number + 1);

        uint256 proposalId = _propose();
        assertEq(0, uint256(votingGovernor.state(proposalId)));

        vm.roll(block.number + votingGovernor.votingDelay() + 1);
        assertEq(1, uint256(votingGovernor.state(proposalId)));

        votingGovernor.castVote(proposalId, 1);

        vm.roll(block.number + votingGovernor.votingPeriod() + 1);
        assertEq(4, uint256(votingGovernor.state(proposalId)));

        votingGovernor.queue(proposalId);
        assertEq(5, uint256(votingGovernor.state(proposalId)));

        vm.expectRevert("TimelockController: operation is not ready");
        votingGovernor.execute(proposalId);
        vm.stopPrank();
    }
}
