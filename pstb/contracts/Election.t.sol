// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Election} from "./Election.sol";
import {Test} from "forge-std/Test.sol";

contract ElectionTest is Test {
    Election election;
    address owner = address(0x1);

    function setUp() public {
        election = new Election(owner);
    }

    function test_OwnerIsSet() public view {
        require(election.owner() == owner, "Owner should be set correctly");
    }

    function test_RegisterCandidateIncrementsAndGrantsRole() public {
        address candidate = address(0x10);
        uint8 candidateId = registerCandidate(candidate);
        assertEq(candidateId, 1);
        assertEq(election.num_candidats(), 1);
        assertTrue(election.hasRole(election.CANDIDAT_VOTER(), candidate));
    }

    function test_RegisterCandidateRequiresMature() public {
        vm.expectRevert("Citizen must be at least 18 years old");
        vm.prank(owner);
        election.registerCandidat("Young", 17, "Lyon", address(0x11));
    }

    function test_RegisterCandidateCannotWhileElectionOngoing() public {
        startElectionAsOwner();
        vm.expectRevert("Election is ongoing");
        vm.prank(owner);
        election.registerCandidat("LateEntry", 35, "Nice", address(0x12));
    }

    function test_VoterRegistrationOnlyDuringElection() public {
        vm.expectRevert("Election is not ongoing");
        vm.prank(owner);
        election.registerVoter("Citizen", 25, "Lyon", address(0x22));
    }

    function test_VoterRegistrationRequiresMaturity() public {
        startElectionAsOwner();
        vm.expectRevert("Citizen must be at least 18 years old");
        vm.prank(owner);
        election.registerVoter("Child", 17, "Paris", address(0x23));
    }

    function test_OwnerOnlyStartAndEndElection() public {
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(address(0x2));
        election.startElection();

        startElectionAsOwner();

        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(address(0x2));
        election.endElection();
    }

    function test_ElectionCannotBeRestartedAfterEnd() public {
        registerCandidate(address(0x45));
        startElectionAsOwner();
        endElectionAsOwner();
        assertTrue(election.paused());

        vm.expectRevert("Pausable: paused");
        vm.prank(owner);
        election.startElection();
    }

    function test_VotingFlowEnforcesRulesAndCountsVotes() public {
        address candidateAddr = address(0x50);
        address voter = address(0x60);
        address voterTwo = address(0x70);
        uint8 candidateId = registerCandidate(candidateAddr);
        startElectionAsOwner();
        registerVoterDuringElection(voter);
        registerVoterDuringElection(voterTwo);

        vm.prank(voter);
        election.vote(candidateId);

        assertEq(election.votesReceived(candidateId), 1);
        assertTrue(election.hasVoted(voter));

        vm.expectRevert("Citizen has already voted");
        vm.prank(voter);
        election.vote(candidateId);

        vm.expectRevert("Invalid candidate ID");
        vm.prank(voterTwo);
        election.vote(0);

        vm.expectRevert();
        vm.prank(address(0x80));
        election.vote(candidateId);

        endElectionAsOwner();
        (uint8 winner, uint32 highest) = election.getWinner();
        assertEq(winner, candidateId);
        assertEq(highest, 1);
    }

    function testFuzz_VotersVoteForWinningCandidate(uint8 votersCount) public {
        vm.assume(votersCount > 0 && votersCount <= 10);
        address candidateAddr = address(0x90);
        uint8 candidateId = registerCandidate(candidateAddr);
        startElectionAsOwner();

        for (uint8 i = 0; i < votersCount; i++) {
            address voter = uniqueVoter(i);
            registerVoterDuringElection(voter);
            vm.prank(voter);
            election.vote(candidateId);
        }

        endElectionAsOwner();
        (uint8 winner, uint32 highest) = election.getWinner();
        assertEq(winner, candidateId);
        assertEq(highest, uint32(votersCount));
    }

    function registerCandidate(address citizen) internal returns (uint8) {
        vm.prank(owner);
        election.registerCandidat("Candidate", 35, "Paris", citizen);
        return election.num_candidats();
    }

    function registerVoterDuringElection(address citizen) internal returns (uint32) {
        vm.prank(owner);
        election.registerVoter("Voter", 30, "Paris", citizen);
        return election.num_voters();
    }

    function startElectionAsOwner() internal {
        vm.prank(owner);
        election.startElection();
    }

    function endElectionAsOwner() internal {
        vm.prank(owner);
        election.endElection();
    }

    function uniqueVoter(uint256 seed) internal pure returns (address) {
        address voter = address(uint160(uint256(keccak256(abi.encodePacked(seed)))));
        if (voter == address(0)) {
            voter = address(uint160(seed + 1));
        }
        return voter;
    }
}
