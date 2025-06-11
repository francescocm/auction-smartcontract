# Auction Smart Contract

This project implements a timed auction smart contract using Solidity. It was deployed on the Sepolia testnet as the final project for Module 2 of the Ethereum programming course. The contract includes features such as bid history tracking, minimum bid increment, auction time extension, commission for the owner, partial refunds, and emergency withdrawal.

## Contract Information

- **Network:** Sepolia Testnet  
- **Contract Address:** 0x164394f0d00c8D2bF85A806998b96e50E7B716cb 
- **Deployer Address:** 0xDBb48A9bAfd93B696e315BDeA68c9a1EBC37c540  
- **Contract Verification:** ✅ Verified on Etherscan https://sepolia.etherscan.io/address/0x164394f0d00c8D2bF85A806998b96e50E7B716cb#code 
- **GitHub Repository:** https://github.com/francescocm/auction-smartcontract  

## Constructor

Initializes the auction with a duration in minutes and sets the deployer as the owner.
```solidity
constructor(uint _durationInMinutes)

**## Main Functionalities**

**placeBid()**
Allows users to place bids before the auction ends.
Each new bid must be at least 5% higher than the current highest bid.
If a bid is placed within the last 10 minutes, the auction end time is extended by 10 minutes.
Records all bids and emits a NewBid event.

**timeLeft()**
Returns the remaining auction time in seconds.
Returns 0 if the auction has ended.

**showWinner()**
Returns the current highest bidder and bid amount.
Most useful after auction ends.

**showBidHistory(address bidder)**
Returns the list of bids placed by the specified address.

**withdrawPartialRefund()**
Allows users to withdraw refundable overbid amounts before auction ends.
Emits PartialRefund event.
Fails if the caller has no refundable amount.

**endAuction()**
Can only be called by the contract owner.
Only callable after the auction time ends.
Transfers 2% commission to the owner.
Refunds all losing bidders.
Emits AuctionEnded event.

**emergencyWithdraw()**
Can only be called by the owner.
Allows withdrawal of leftover funds after auction ends.

**Bid and Refund Management**
All ETH bids are stored in the contract.
Losing bidders are refunded either automatically when the auction ends or manually via withdrawPartialRefund if applicable.
The contract uses mappings to track refundable balances and full bid history.

📌 **Events**
event NewBid(address indexed bidder, uint amount);
event AuctionEnded(address winner, uint amount);
event PartialRefund(address indexed bidder, uint amount);

🔒 **Modifiers**
onlyOwner: Restricts access to sensitive functions like endAuction and emergencyWithdraw.

🛠 **Modifications & Notes**
Implemented a minimum bid increment of 5% to ensure meaningful increases.
Auction end time extends by 10 minutes if a bid is placed near the end.
Stored full bid history per user for transparency.
Partial refund mechanism: bidders can recover funds from overbids before the auction ends.
The owner receives a 2% commission upon finalizing the auction.
Emergency withdrawal is available after finalization to recover any leftover funds.
Revert messages are included for clarity (e.g., "notOwner", "ended", "lowBid", "noRefund").
The contract is for educational purposes only and does not involve physical item transfer.

**Author**
Francesco Centarti Maestu
Ethereum Programming - Module 2 Final Project
