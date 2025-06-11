// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Auction contract with owner-controlled finalization and partial refunds
/// @author Francesco Centarti Maestu
/// @notice Implements a timed auction with incremental bids, commission, partial refunds, and emergency withdrawal
contract Auction {
    address public owner;
    uint public auctionEndTime;
    address public highestBidder;
    uint public highestBid;
    bool public auctionEnded;
    uint constant COMMISSION_RATE = 2; // 2% commission
    uint constant MIN_INCREMENT_PERCENT = 5; // Minimum 5% increase to outbid
    uint constant EXTENSION_TIME = 10 minutes;

    mapping(address => uint) public bids;
    mapping(address => uint[]) public bidHistory;
    mapping(address => uint) public refundableBalances;

    address[] private biddersList;

    event NewBid(address indexed bidder, uint amount);
    event AuctionEnded(address winner, uint amount);
    event PartialRefund(address indexed bidder, uint amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "notOwner");
        _;
    }

    constructor(uint _durationInMinutes) {
        owner = msg.sender;
        auctionEndTime = block.timestamp + (_durationInMinutes * 1 minutes);
    }

    function timeLeft() external view returns (uint) {
        if (block.timestamp >= auctionEndTime) {
            return 0;
        }
        return auctionEndTime - block.timestamp;
    }

    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "ended");
        require(msg.value > 0, "zero");

        uint minRequired = highestBid == 0 ? 0 : highestBid + (highestBid * MIN_INCREMENT_PERCENT) / 100;
        require(msg.value > minRequired, "lowBid");

        if (bids[msg.sender] > 0) {
            refundableBalances[msg.sender] += bids[msg.sender];
        } else {
            biddersList.push(msg.sender);
        }

        bids[msg.sender] = msg.value;
        bidHistory[msg.sender].push(msg.value);

        highestBidder = msg.sender;
        highestBid = msg.value;

        if (auctionEndTime - block.timestamp <= EXTENSION_TIME) {
            auctionEndTime += EXTENSION_TIME;
        }

        emit NewBid(msg.sender, msg.value);
    }

    function showWinner() external view returns (address winner, uint bid) {
        return (highestBidder, highestBid);
    }

    function showBidHistory(address bidder) external view returns (uint[] memory) {
        return bidHistory[bidder];
    }

    function withdrawPartialRefund() external {
        uint amount = refundableBalances[msg.sender];
        require(amount > 0, "noRefund");

        // Reset refundable balance before transfer to prevent re-entrancy
        refundableBalances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);

        emit PartialRefund(msg.sender, amount);
    }

    function endAuction() external onlyOwner {
        require(block.timestamp >= auctionEndTime, "ongoing");
        require(!auctionEnded, "ended");

        auctionEnded = true;

        uint commission = (highestBid * COMMISSION_RATE) / 100;

        // Transfer commission to owner first
        payable(owner).transfer(commission);

        uint biddersCount = biddersList.length;

        for (uint i = 0; i < biddersCount; i++) {
            address bidder = biddersList[i];
            if (bidder != highestBidder) {
                uint refundAmount = bids[bidder];
                if (refundAmount > 0) {
                    bids[bidder] = 0;
                    payable(bidder).transfer(refundAmount);
                }
            }
        }

        emit AuctionEnded(highestBidder, highestBid);
    }

    function emergencyWithdraw() external onlyOwner {
        require(auctionEnded, "notFinalized");
        payable(owner).transfer(address(this).balance);
    }
}
