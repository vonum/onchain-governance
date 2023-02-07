// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {VotingGovernor} from "../src/VotingGovernor.sol";
import {BaseVotingGovernorTest} from "./BaseVotingGovernor.t.sol";

contract VotingGovernorProposalsTest is BaseVotingGovernorTest {
    function testPropose() public {
        vm.startPrank(owner);
        uint256 balance = votingToken.balanceOf(owner);
        assertEq(1000, balance);

        votingToken.delegate(owner);
        vm.roll(block.number + 1);

        uint256 nVotes = votingToken.getVotes(owner);
        assertEq(1000, nVotes);

        uint256 proposalId = _propose();
        vm.stopPrank();

        assertEq(
            uint256(ProposalState.Pending),
            uint256(votingGovernor.state(proposalId))
        );
    }

    function testRevertProposeNotEnoughTokens() public {
        vm.prank(noone);
        vm.expectRevert("Governor: proposer votes below proposal threshold");
        _propose();
    }

    function testVote() public {
        vm.startPrank(owner);
        votingToken.delegate(noone);
        vm.roll(block.number + 1);

        uint256 delegatedVotes = votingToken.getVotes(noone);
        assertEq(1000, delegatedVotes);
        vm.roll(block.number + 1);
        vm.stopPrank();

        vm.startPrank(noone);
        uint256 proposalId = _propose();
        assertEq(
            uint256(ProposalState.Pending),
            uint256(votingGovernor.state(proposalId))
        );

        vm.roll(block.number + votingGovernor.votingDelay() + 1);
        assertEq(
            uint256(ProposalState.Active),
            uint256(votingGovernor.state(proposalId))
        );

        votingGovernor.castVote(proposalId, uint8(Vote.For));
        vm.stopPrank();

        vm.roll(block.number + 10);

        uint256 nVotes = votingGovernor.getVotes(noone, block.number - 1);
        assertEq(1000, nVotes);
    }

    function testVotingNotStartedYet() public {
        vm.startPrank(owner);
        votingToken.delegate(owner);
        vm.roll(block.number + 1);

        uint256 delegatedVotes = votingToken.getVotes(owner);
        assertEq(1000, delegatedVotes);

        uint256 proposalId = _propose();
        assertEq(
            uint256(ProposalState.Pending),
            uint256(votingGovernor.state(proposalId))
        );

        vm.expectRevert("Governor: vote not currently active");
        votingGovernor.castVote(proposalId, uint8(Vote.For));
        vm.stopPrank();
    }

    function testCancelProposal() public {
        vm.startPrank(owner);
        votingToken.delegate(owner);
        vm.roll(block.number + 1);

        uint256 proposalId = _propose();
        assertEq(
            uint256(ProposalState.Pending),
            uint256(votingGovernor.state(proposalId))
        );

        votingGovernor.cancel(proposalId);
        vm.stopPrank();
        assertEq(
            uint256(ProposalState.Canceled),
            uint256(votingGovernor.state(proposalId))
        );
    }

    function testCancelProposalNonProposer() public {
        vm.startPrank(owner);
        votingToken.delegate(owner);
        vm.roll(block.number + 1);

        uint256 proposalId = _propose();
        assertEq(
            uint256(ProposalState.Pending),
            uint256(votingGovernor.state(proposalId))
        );
        vm.stopPrank();

        vm.prank(noone);
        vm.expectRevert("GovernorBravo: proposer above threshold");
        votingGovernor.cancel(proposalId);
    }

    function testProposalSucceeded() public {
        vm.startPrank(owner);
        votingToken.delegate(owner);
        vm.roll(block.number + 1);

        uint256 proposalId = _propose();
        assertEq(
            uint256(ProposalState.Pending),
            uint256(votingGovernor.state(proposalId))
        );

        vm.roll(block.number + votingGovernor.votingDelay() + 1);
        assertEq(
            uint256(ProposalState.Active),
            uint256(votingGovernor.state(proposalId))
        );

        votingGovernor.castVote(proposalId, uint8(Vote.For));
        vm.stopPrank();

        vm.roll(block.number + votingGovernor.votingPeriod() + 1);
        assertEq(
            uint256(ProposalState.Succeeded),
            uint256(votingGovernor.state(proposalId))
        );
    }

    function testProposalDefeated() public {
        vm.startPrank(owner);
        votingToken.delegate(owner);
        vm.roll(block.number + 1);

        uint256 proposalId = _propose();
        assertEq(
            uint256(ProposalState.Pending),
            uint256(votingGovernor.state(proposalId))
        );
        vm.stopPrank();

        vm.roll(block.number + votingGovernor.votingDelay() + 1);
        assertEq(
            uint256(ProposalState.Active),
            uint256(votingGovernor.state(proposalId))
        );

        vm.roll(block.number + votingGovernor.votingPeriod() + 1);
        assertEq(
            uint256(ProposalState.Defeated),
            uint256(votingGovernor.state(proposalId))
        );
    }
}
