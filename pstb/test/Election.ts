import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.connect();

describe("Election integration flows", function () {
  it("runs the happy path and observes the paused winner", async function () {
    const [owner, candidate, voterOne, voterTwo] = await ethers.getSigners();

    const election = await ethers.deployContract("Election", [owner.address]);

    await election
      .connect(owner)
      .registerCandidat("Alice Candidate", 36, "Paris", candidate.address);
    await election.connect(owner).startElection();

    await election
      .connect(owner)
      .registerVoter("Voter One", 29, "Lyon", voterOne.address);
    await election
      .connect(owner)
      .registerVoter("Voter Two", 33, "Nice", voterTwo.address);

    await election.connect(voterOne).vote(1);
    await election.connect(voterTwo).vote(1);

    await election.connect(owner).endElection();

    const [winnerId, totalVotes] = await election.getWinner();
    expect(winnerId).to.equal(1);
    expect(totalVotes).to.equal(2);
    expect(await election.paused()).to.equal(true);
  });

  it("rejects lifecycle actions from non-owners", async function () {
    const [owner, , voterOne] = await ethers.getSigners();

    const election = await ethers.deployContract("Election", [owner.address]);

    await expect(election.connect(voterOne).startElection()).to.revert(ethers);
    await election.connect(owner).startElection();
    await expect(election.connect(voterOne).endElection()).to.revert(ethers);
    await election.connect(owner).endElection();
  });
});
