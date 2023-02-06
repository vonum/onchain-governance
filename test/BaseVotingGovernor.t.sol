// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import {Test} from "forge-std/Test.sol";
import {Token} from "../src/Token.sol";
import {VotingToken} from "../src/VotingToken.sol";
import {VotingGovernor} from "../src/VotingGovernor.sol";

import {TimelockController} from "openzeppelin-contracts/contracts/governance/TimelockController.sol";

contract BaseVotingGovernorTest is Test {
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
        votingGovernor = new VotingGovernor(votingToken, timelockController);

        usdc.transfer(address(timelockController), 1000);

        vm.stopPrank();
    }

    function testVotingDelay() public {
        assertEq(6575, votingGovernor.votingDelay());
    }

    function testVotingPeriod() public {
        assertEq(46027, votingGovernor.votingPeriod());
    }

    function testProposalTreshold() public {
        assertEq(10, votingGovernor.proposalThreshold());
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

    function _queue() internal {
        address[] memory targets = new address[](1);
        targets[0] = address(usdc);
        uint256[] memory values = new uint256[](1);
        // values[0] = 0
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = abi.encodeWithSignature("transfer(address,uint256)", noone, 100);
        // string memory description = "Description";
        bytes32 description = bytes32(bytes("Description"));

        votingGovernor.queue(
            targets,
            values,
            calldatas,
            description
        );
    }
}
