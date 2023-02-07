// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import {IGovernor, Governor} from "openzeppelin-contracts/contracts/governance/Governor.sol";
import {GovernorCompatibilityBravo} from "openzeppelin-contracts/contracts/governance/compatibility/GovernorCompatibilityBravo.sol";
import {GovernorVotes} from "openzeppelin-contracts/contracts/governance/extensions/GovernorVotes.sol";
import {GovernorVotesQuorumFraction} from "openzeppelin-contracts/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import {GovernorTimelockControl} from "openzeppelin-contracts/contracts/governance/extensions/GovernorTimelockControl.sol";

import {IERC165} from "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";
import {IVotes} from "openzeppelin-contracts/contracts/governance/utils/IVotes.sol";
import {TimelockController} from "openzeppelin-contracts/contracts/governance/TimelockController.sol";

contract VotingGovernor is
    Governor,
    GovernorCompatibilityBravo,
    GovernorVotes,
    GovernorVotesQuorumFraction,
    GovernorTimelockControl {
    uint256 public constant BLOCKS_IN_1_DAY = 6575;
    uint256 public constant BLOCKS_IN_1_WEEK = 46027;
    uint256 public constant PROPOSAL_TRESHOLD = 10;

    uint256 public immutable govVotingDelay;
    uint256 public immutable govVotingPeriod;
    uint256 public immutable govProposalTreshold;
    uint256 public immutable govQuorum;

    constructor(
        IVotes _token,
        TimelockController _timelock,
        uint256 _votingDelay,
        uint256 _votingPeriod,
        uint256 _proposalTreshold,
        uint256 _quorum
    )
        Governor("VotingGovernor")
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(_quorum)
        GovernorTimelockControl(_timelock)
    {
        govVotingDelay = _votingDelay;
        govVotingPeriod = _votingPeriod;
        govProposalTreshold = _proposalTreshold;
        govQuorum = _quorum;
    }

    function votingDelay() public view override returns (uint256) {
        return govVotingDelay;
    }

    function votingPeriod() public view override returns (uint256) {
        return govVotingPeriod;
    }

    function proposalThreshold() public view override returns (uint256) {
        return govProposalTreshold;
    }

    // The functions below are overrides required by Solidity.
    function state(uint256 proposalId)
        public
        view
        override(Governor, IGovernor, GovernorTimelockControl)
        returns (ProposalState)
    {
        return super.state(proposalId);
    }

    function propose(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, string memory description)
        public
        override(Governor, GovernorCompatibilityBravo, IGovernor)
        returns (uint256)
    {
        return super.propose(targets, values, calldatas, description);
    }

    function _execute(uint256 proposalId, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
        internal
        override(Governor, GovernorTimelockControl)
    {
        super._execute(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _cancel(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
        internal
        override(Governor, GovernorTimelockControl)
        returns (uint256)
    {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor()
        internal
        view
        override(Governor, GovernorTimelockControl)
        returns (address)
    {
        return super._executor();
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(Governor, IERC165, GovernorTimelockControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
