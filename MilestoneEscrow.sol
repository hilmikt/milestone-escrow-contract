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

    /// @dev Event emitted when work is submitted
    event WorkSubmitted(uint indexed jobId, uint indexed milestoneId);

    /// @dev Event emited when milestone is approved
    event MilestoneApproved(uint indexed jobId, uint indexed milestoneId, uint amount);

    /// @notice Freelancer submits work for a milestone
    function submitWork(uint jobId, uint milestoneId) external onlyFreelancer(jobId) {
        Job storage job = jobs[jobId];
        require(job.status == JobStatus.Active, "Job is not active");
        require(milestoneId < job.milestoneCount, "Invalid milestone");
        require(!job.milestones[milestoneId].isReleased, "Milestone already released");

        emit WorkSubmitted(jobId, milestoneId);
    }

    /// @notice Client approves and releases payment for a milestone
    function approveMilestone(uint jobId, uint milestoneId) external onlyClient(jobId) {
        Job storage job = jobs[jobId];
        require(job.status == JobStatus.Active, "Job is not active");
        require(milestoneId < job.milestoneCount, "Invalid milestone");
        require(!job.milestones[milestoneId].isReleased, "Already released");

        uint amount = job.milestones[milestoneId].amount;
        job.milestones[milestoneId].isReleased = true;
        payable(job.freelancer).transfer(amount);

        emit MilestoneApproved(jobId, milestoneId, amount);

        // Optional: mark job completed if all milestones released
        bool allReleased = true;
        for (uint i = 0; i < job.milestoneCount; i++) {
            if (!job.milestones[i].isReleased) {
                allReleased = false;
                break;
            }
        }

        if (allReleased) {
            job.status = JobStatus.Completed;
        }
    }

    /// @dev Event emitted when a job is cancelled and refunded
    event JobCancelled(uint indexed jobId, uint refundedAmount);

    /// @notice Allows client to cancel the job before any milestone is approved
    function cancelJob(uint jobId) external onlyClient(jobId) {
        Job storage job = jobs[jobId];
        require(job.status == JobStatus.Active, "Job is not active");

        // Check no milestones are released yet
        for (uint i=0; i < job.milestoneCount; i++) {
            require(!job.milestones[i].isReleased, "Milestone already released");
        }
        
        uint refundAmount = address(this).balance;
        job.status = JobStatus.Cancelled;
        payable(job.client).transfer(refundAmount);

        emit JobCancelled(jobId, refundAmount);
    }
}