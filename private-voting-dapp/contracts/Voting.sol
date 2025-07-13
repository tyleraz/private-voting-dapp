// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@fhevm/solidity/TFHE.sol";

contract Voting {
    // The number of candidates.
    uint public numCandidates;
    // The end date of the voting.
    uint public endDate;

    // Mapping from address to boolean to check if an address has voted.
    mapping(address => bool) public hasVoted;
    // Mapping from candidate index to their encrypted vote count.
    mapping(uint => euint32) public votes;

    // Event to be emitted when a vote is cast.
    event Voted(address voter, uint candidate);

    // The constructor is called when the contract is deployed.
    constructor(uint _numCandidates, uint _endDate) {
        numCandidates = _numCandidates;
        endDate = _endDate;
    }

    // Function to cast a vote.
    function vote(uint _candidate, bytes calldata _proof) public {
        // Check if the voting has ended.
        require(block.timestamp < endDate, "Voting has ended");
        // Check if the candidate is valid.
        require(_candidate < numCandidates, "Invalid candidate");
        // Check if the voter has already voted.
        require(!hasVoted[msg.sender], "You have already voted");

        // Mark the voter as having voted.
        hasVoted[msg.sender] = true;

        // Add 1 to the encrypted vote count of the candidate.
        votes[_candidate] = TFHE.add(votes[_candidate], TFHE.asEuint32(1, _proof));

        // Emit the Voted event.
        emit Voted(msg.sender, _candidate);
    }

    // Function to get the number of votes for a candidate.
    function getVotes(uint _candidate) public view returns (uint) {
        // Check if the candidate is valid.
        require(_candidate < numCandidates, "Invalid candidate");
        // Decrypt the vote count and return it.
        return TFHE.decrypt(votes[_candidate]);
    }
}
