import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const EXISTING_ELECTION = "0x8DCC87FaeEE2dd8A74CEaecFc9959faA3066f5C1";

export default buildModule("ElectionInteractor", (m) => {
  const ownerAccount = m.getAccount(0);
  const candidateAccount = m.getAccount(1);
  const voterOneAccount = m.getAccount(2);
  const voterTwoAccount = m.getAccount(3);

  const election = m.contractAt("Election", EXISTING_ELECTION);

  const registerCandidate = m.call(
    election,
    "registerCandidat",
    ["Ignition Candidate", 37, "Paris", candidateAccount],
    { id: "RegisterCandidate", from: ownerAccount },
  );

  const startElection = m.call(election, "startElection", [], {
    id: "StartElection",
    from: ownerAccount,
    after: [registerCandidate],
  });

  const registerVoterOne = m.call(
    election,
    "registerVoter",
    ["Voter One", 30, "Lyon", voterOneAccount],
    { id: "RegisterVoterOne", from: ownerAccount, after: [startElection] },
  );

  const registerVoterTwo = m.call(
    election,
    "registerVoter",
    ["Voter Two", 33, "Nice", voterTwoAccount],
    {
      id: "RegisterVoterTwo",
      from: ownerAccount,
      after: [startElection, registerVoterOne],
    },
  );

  const voteOne = m.call(
    election,
    "vote",
    [1n],
    { id: "VoteOne", from: voterOneAccount, after: [registerVoterOne] },
  );

  const voteTwo = m.call(
    election,
    "vote",
    [1n],
    { id: "VoteTwo", from: voterTwoAccount, after: [registerVoterTwo, voteOne] },
  );

  const endElection = m.call(election, "endElection", [], {
    id: "EndElection",
    after: [voteOne, voteTwo],
  });

  const winnerId = m.staticCall(election, "getWinner", [], 0, {
    id: "WinnerId",
    after: [endElection],
  });
  const highestVotes = m.staticCall(election, "getWinner", [], 1, {
    id: "HighestVotes",
    after: [endElection],
  });
  const isPaused = m.staticCall(election, "paused", [], undefined, {
    id: "IsPaused",
    after: [endElection],
  });

  return {
    election,
    registerCandidate,
    startElection,
    registerVoterOne,
    registerVoterTwo,
    voteOne,
    voteTwo,
    endElection,
    winnerId,
    highestVotes,
    isPaused,
  };
});
