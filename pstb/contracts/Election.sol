//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Election is Ownable {

    // Read/write candidate
    struct Candidate {
        uint8 id;
        string name;
        uint voteCount;
    }

    mapping(address => bool) public voters;
    mapping(uint => Candidate) public candidates;
    uint8 public candidatesCount;

    event Voted(uint _candidate, uint _votes);
    event NewCandidate(string _candidate, uint _candidateId);
    event VotingIsOpen();

    // Constructor
    constructor () Ownable() {}

    modifier onlyUnvoted() {
        require(!voters[msg.sender], 'Already voted');
        _;
    }

    modifier onlyCandidates(uint _candidateId) {
        require(_candidateId > 0 && _candidateId <= candidatesCount);
        _;
    }

    modifier isVotingOpen() {
        require(owner() == address(0), 'Voting is closed');
        _;
    }

    modifier isVotingClosed() {
        require(owner() != address(0), 'Voting is open');
        _;
    }

    function renounceOwnership() public override {
        super.renounceOwnership();
        emit VotingIsOpen();
    }

    function vote (uint _candidateId) external isVotingOpen() onlyUnvoted() onlyCandidates(_candidateId) {
        // record that voter has voted
        voters[msg.sender] = true;

        // update candidate vote Count
        candidates[_candidateId].voteCount ++;

        // emit the voted event
        emit Voted(_candidateId, candidates[_candidateId].voteCount);
    }

    function addCandidate (string calldata _name) public isVotingClosed() onlyOwner() {
        candidatesCount++;
        Candidate storage c = candidates[candidatesCount];
        c.id = candidatesCount;
        c.name = _name;
        c.voteCount = 0;

        // emit the voted event
        emit NewCandidate(_name, candidatesCount);
    }
}