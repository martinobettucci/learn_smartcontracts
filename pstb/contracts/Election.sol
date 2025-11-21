//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract Election is Ownable, AccessControl, Pausable {

    // Une personne qui s'est enregistrée pour voter
    bytes32 public constant REGISTER_VOTER = keccak256("REGISTER_VOTER");
    // Un candidat qui peut être voté
    bytes32 public constant CANDIDAT_VOTER = keccak256("CANDIDAT_VOTER");

    // Les participants aux ballotins (votants ou candidats)
    struct Citizen {
        string name;
        uint8 age;
        string city;
        address citizenAddress;
    }

    // Les candidats à l'élection
    uint8 public num_candidats = 0;
    mapping (uint8 => Citizen) public candidats;
    // le programme d'un candidat
    mapping (uint8 candidat => string) public candidatProgram;

    // les votants enregistrés
    uint32 public num_voters = 0;
    mapping (uint32 => Citizen) public voters;

    // qui a voté
    mapping (address citizen => bool) public hasVoted;
    // qui a reçu combien de votes
    mapping (uint8 candidat => uint32 votes) public votesReceived;

    // Un nouveau condidat s'est presenté aux elections!
    event CandidatRegistered(uint8 candidateId, string name, uint8 age, string city, address citizenAddress);
    event ElectionStarted();
    event ElectionEnded();
    event VoteCasted();

    // Election ouvertes ou fermées
    bool electionOngoing = false;

    // Initialiser le contrat avec le propriétaire
    constructor(address initialOwner) Ownable(initialOwner) {
        _grantRole(DEFAULT_ADMIN_ROLE, initialOwner);
    }

    // est major?
    modifier isMature(uint8 age) {
        require(age >= 18, "Citizen must be at least 18 years old");
        _;
    }

    // election en cours?
    modifier whenElectionOngoing() {
        require(electionOngoing, "Election is not ongoing");
        _;
    }

    // election pas en cours?
    modifier whenElectionNotOngoing() {
        require(!electionOngoing, "Election is ongoing");
        _;
    }

    // n'a pas encore voté?
    modifier onlyUnvoted() {
        require(!hasVoted[msg.sender], "Citizen has already voted");
        _; 
    }

    // Enregistrer un candidat
    function registerCandidat(string memory name, uint8 age, string memory city, address citizen) 
        isMature(age) 
        whenElectionNotOngoing
        public
    {
        // ne pas s'enregistrer deux fois
        require(!hasRole(CANDIDAT_VOTER, citizen), "Candidat already registered");

        num_candidats++;
        candidats[num_candidats] = Citizen(name, age, city, citizen);
        _grantRole(CANDIDAT_VOTER, citizen);
        emit CandidatRegistered(num_candidats, name, age, city, citizen);
    }

    // Enregistrer un votant
    function registerVoter(string memory name, uint8 age, string memory city, address citizen) 
        isMature(age) 
        whenElectionOngoing
        public
    {
        // ne pas s'enregistrer deux fois
        require(!hasRole(REGISTER_VOTER, citizen), "Voter already registered");

        num_voters++;
        voters[num_voters] = Citizen(name, age, city, citizen);
        _grantRole(REGISTER_VOTER, citizen);    
    }

    // Démarrer l'élection
    function startElection() 
        onlyOwner 
        whenElectionNotOngoing 
        whenNotPaused
        public
    {
        emit ElectionStarted();
        electionOngoing = true;
    }

    // Terminer l'élection
    function endElection() 
        onlyOwner 
        whenElectionOngoing 
        public
    {
        emit ElectionEnded();
        electionOngoing = false;
        _pause();
    }

    // qui a gagne?
    function getWinner() 
        public 
        view 
        whenElectionNotOngoing 
        returns (uint8 winnerId, uint32 highestVotes) 
    {
        uint32 maxVotes = 0;
        uint8 winningCandidateId = 0;  
        for (uint8 i = 1; i <= num_candidats; i++) {
            if (votesReceived[i] > maxVotes) {
                maxVotes = votesReceived[i];
                winningCandidateId = i;
            }
        }
        return (winningCandidateId, maxVotes);
    }

    // Voter pour un candidat
    function vote(uint8 candidateId) 
        whenElectionOngoing  
        onlyRole(REGISTER_VOTER)
        onlyUnvoted
        public
    {
        require(candidateId > 0 && candidateId <= num_candidats, "Invalid candidate ID");
        votesReceived[candidateId]++;
        hasVoted[msg.sender] = true;
        emit VoteCasted();
    }

}
