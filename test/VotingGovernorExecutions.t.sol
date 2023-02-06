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

        console.logBytes32(bytes32(bytes("Description")));

        vm.roll(block.number + 15);
        votingGovernor.queue(proposalId);

        // _queue();
        assertEq(5, uint256(votingGovernor.state(proposalId)));
        vm.stopPrank();
    }

    function testDefeatedProposalQueue() public {

    }

    function testProposalExecutionSuccess() public {

    }

    function testProposalExecutionNonExecutor() public {

    }

    function testProposalExecutionEffects() public {

    }
}
