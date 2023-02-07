// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {Test} from "forge-std/Test.sol";
import {Token} from "../src/tokens/Token.sol";
import {VotingToken} from "../src/tokens/VotingToken.sol";
import {VotingGovernor} from "../src/VotingGovernor.sol";

import {TimelockController} from "openzeppelin-contracts/contracts/governance/TimelockController.sol";

contract BaseVotingGovernorTest is Test {
    enum ProposalState {
        Pending,
        Active,
        Canceled,
        Defeated,
        Succeeded,
        Queued,
        Expired,
        Executed
    }

    enum Vote {
        Against,
        For,
        Abstain
    }

    uint256 public constant BLOCKS_IN_1_DAY = 6575;
    uint256 public constant BLOCKS_IN_1_WEEK = 46027;
    uint256 public constant PROPOSAL_TRESHOLD = 10;
    uint256 public constant QUORUM = 4;

    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");

    uint256 internal constant MIN_DELAY = 10;
    address internal immutable owner = vm.addr(0x1);
    address internal immutable executor = vm.addr(0x2);
    address internal immutable noone = vm.addr(0x3);

    address[] internal proposers = new address[](1);
    address[] internal executors = new address[](1);

    Token internal usdc;
    VotingToken internal votingToken;
    VotingGovernor internal votingGovernor;
    TimelockController internal timelockController;

    function setUp() public virtual {
       proposers[0] = owner;
       executors[0] = executor;

        vm.startPrank(owner);

        usdc = new Token("USDC", "USDC", 1000);
        votingToken = new VotingToken(1000);
        timelockController = new TimelockController(
            MIN_DELAY,
            proposers,
            executors,
            owner
        );
        votingGovernor = new VotingGovernor(
            votingToken,
            timelockController,
            BLOCKS_IN_1_DAY,
            BLOCKS_IN_1_WEEK,
            PROPOSAL_TRESHOLD,
            QUORUM
        );

        timelockController.grantRole(PROPOSER_ROLE, address(votingGovernor));
        timelockController.grantRole(EXECUTOR_ROLE, address(votingGovernor));

        usdc.transfer(address(timelockController), 1000);

        vm.stopPrank();
    }

    function testVotingDelay() public {
        assertEq(BLOCKS_IN_1_DAY, votingGovernor.votingDelay());
    }

    function testVotingPeriod() public {
        assertEq(BLOCKS_IN_1_WEEK, votingGovernor.votingPeriod());
    }

    function testProposalTreshold() public {
        assertEq(PROPOSAL_TRESHOLD, votingGovernor.proposalThreshold());
    }

    function testQuorum() public {
        assertEq(QUORUM, votingGovernor.quorumNumerator());
    }

    function _propose() internal returns (uint256) {
        address[] memory targets = new address[](1);
        targets[0] = address(usdc);
        uint256[] memory values = new uint256[](1);
        // values[0] = 0
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = abi.encodeWithSignature("transfer(address,uint256)", noone, 100);
        string memory description = "Description";

        uint256 proposalId = votingGovernor.propose(
            targets,
            values,
            calldatas,
            description
        );

        return proposalId;
    }
}
