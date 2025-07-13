// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Milestone Escrow Contract for Freelance Wrok (Mintaro Prototype)
/// @author Hilmi
/// @notice Enables secure ETH payment flows based on job milestones between client and freelancer

contract MilestoneEscrow {
    // Job status enumeration
    enum JobStatus { Active, Completed, Cancelled }

    // Milestone data
    struct Milestone {
        uint amount;
        bool isReleased;
    }

    // Job details
    struct Job {
        address client;
        address freelancer;
        uint totalAmount;
        JobStatus status;
        uint milestoneCount;
        mapping(uint => Milestone) milestones;
    }

    uint public jobCounter; // unique job ID tracker
    mapping(uint => Job) public jobs;

    /// @dev Restrict action to job creator (client
    modifier onlyClient(uint jobId) {
        require(msg.sender == jobs[jobId].client, "Only client can perform this action");
        _;
    }

    /// @dev Restrict action to assigned freelancer
    modifier onlyFreelancer(uint jobId) {
        require(msg.sender == jobs[jobId].freelancer, "Only freelancer can perform this action");
        _;
    }

    /// @notice Create a new job with ETH locked for milestone payments
    /// @param _freelancer Address of freelancer
    /// @param _milestoneAmounts Array of milestone payouts in wei
    function createJob(address _freelancer, uint[] calldata _milestoneAmounts) external payable {
        require(_freelancer != address(0), "Invalid freelancer address");
        require(_milestoneAmounts.length > 0, "At least one milestone required");

        uint total;
        for (uint i=0; i < _milestoneAmounts.length; i++) {
            total += _milestoneAmounts[i];
        }

        require(msg.value == total, "ETH send must equal total milestone amount");

        jobCounter++;
        Job storage newJob = jobs[jobCounter];
        newJob.client = msg.sender;
        newJob.freelancer = _freelancer;
        newJob.totalAmount = total;
        newJob.status = JobStatus.Active;
        newJob.milestoneCount = _milestoneAmounts.length;

        for (uint i=0; i< _milestoneAmounts.length; i++) {
            newJob.milestones[i] = Milestone(_milestoneAmounts[i], false);
        }

    }
}