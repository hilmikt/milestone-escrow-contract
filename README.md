# ⛓️ Milestone Escrow Smart Contract

A decentralized, milestone-based escrow smart contract built with Solidity. This contract allows clients to lock ETH for freelancers and release payments step-by-step as work milestones are approved.

Ideal for freelance work agreements, this smart contract is part of the **Mintaro** protocol and focuses on creating transparent, trustless relationships between clients and talent on the blockchain.

***

## 📦 Features

- Clients can create jobs and fund them in advance  
- ETH is divided into milestones  
- Freelancers submit work per milestone  
- Clients approve and release milestone funds  
- Transparent and non-custodial escrow logic  
- Role-based access (`onlyClient`, `onlyFreelancer`)  
- Easily expandable to include deadlines, disputes, or DAO-based arbitration  

***

## 🛠️ Technologies Used

- Solidity `^0.8.20`  
- Remix IDE for development  
- MetaMask for wallet connection  
- Sepolia Testnet for deployment  
- Ethers.js for frontend integration  

***

## 🚀 Getting Started

### 1. Clone the Repo

***Run this in your terminal:***

`git clone https://github.com/hilmikt/milestone-escrow-contract.git`

### 2. Open in Remix

- Paste `MilestoneEscrow.sol` into **Remix IDE**  
- Compile using version **0.8.20**  
- Deploy to **Sepolia** using **Injected Provider (MetaMask)**  
- Copy the deployed contract **address** and **ABI** for frontend use  

***

## 🔒 Security Notes

- ETH is locked per job at creation  
- Funds are released only per milestone approval  
- Refund/dispute logic not yet included *(planned in v2)*  

***

## 👤 Author

**Hilmi KT**  
Blockchain Developer | Web3 Startup Builder  
[LinkedIn →](https://www.linkedin.com/in/hilmi-kt)

***

## 📜 License

Licensed under the **MIT License**
