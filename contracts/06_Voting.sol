// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Voting
/// @notice Chairperson authorizes voters; each authorized voter votes once
contract Voting {
    struct Candidate {
        string name;
        uint256 voteCount;
    }

    struct Voter {
        bool authorized;
        bool voted;
        uint256 voteIndex;
    }

    Candidate[] public candidates;
    mapping(address => Voter) public voters;
    address public chairperson;

    event VoterAuthorized(address indexed voter);
    event Voted(address indexed voter, uint256 indexed candidateIndex);

    modifier onlyChairperson() {
        require(msg.sender == chairperson, "Only chairperson");
        _;
    }

    constructor(string[] memory candidateNames) {
        require(candidateNames.length > 0, "Need at least one candidate");
        chairperson = msg.sender;
        for (uint256 i = 0; i < candidateNames.length; i++) {
            candidates.push(Candidate({name: candidateNames[i], voteCount: 0}));
        }
    }

    function authorize(address voter) external onlyChairperson {
        require(voter != address(0), "Invalid address");
        require(!voters[voter].authorized, "Already authorized");
        voters[voter].authorized = true;
        emit VoterAuthorized(voter);
    }

    function vote(uint256 candidateIndex) external {
        Voter storage v = voters[msg.sender];
        require(v.authorized, "Not authorized to vote");
        require(!v.voted, "Already voted");
        require(candidateIndex < candidates.length, "Invalid candidate");

        v.voted = true;
        v.voteIndex = candidateIndex;
        candidates[candidateIndex].voteCount += 1;

        emit Voted(msg.sender, candidateIndex);
    }

    function totalVotes(uint256 candidateIndex) external view returns (uint256) {
        require(candidateIndex < candidates.length, "Invalid candidate");
        return candidates[candidateIndex].voteCount;
    }

    function winnerName() external view returns (string memory) {
        uint256 winningIndex = 0;
        uint256 highest = 0;
        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > highest) {
                highest = candidates[i].voteCount;
                winningIndex = i;
            }
        }
        return candidates[winningIndex].name;
    }
}