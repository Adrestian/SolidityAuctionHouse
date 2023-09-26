// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Auction.sol";

contract VickreyAuction is Auction {

    uint public minimumPrice;
    uint public biddingDeadline;
    uint public revealDeadline;
    uint public bidDepositAmount;

    // TODO: place your code here
    mapping(address => bytes32) commitment;
    uint internal secondHighestPrice;
    uint internal HighestPrice;

    // constructor
    constructor(address _sellerAddress,
                            address _judgeAddress,
                            address _timerAddress,
                            uint _minimumPrice,
                            uint _biddingPeriod,
                            uint _revealPeriod,
                            uint _bidDepositAmount)
             Auction (_sellerAddress, _judgeAddress, _timerAddress) {

        minimumPrice = _minimumPrice;
        bidDepositAmount = _bidDepositAmount;
        biddingDeadline = time() + _biddingPeriod;
        revealDeadline = time() + _biddingPeriod + _revealPeriod;
        auctionEnd = revealDeadline;

        // TODO: place your code here
        secondHighestPrice = minimumPrice;
        HighestPrice = minimumPrice;

    }

    // Record the player's bid commitment
    // Make sure exactly bidDepositAmount is provided (for new bids)
    // Bidders can update their previous bid for free if desired.
    // Only allow commitments before biddingDeadline
    function commitBid(bytes32 bidCommitment) public payable {
        // TODO: place your code here
        require(time() < biddingDeadline);

        if (commitment[msg.sender] == 0){
            require(msg.value == bidDepositAmount);
            commitment[msg.sender] = bidCommitment;
        } else{
            require(msg.value == 0);
            commitment[msg.sender] = bidCommitment;
        }
    }

    // Check that the bid (msg.value) matches the commitment.
    // If the bid is correctly opened, the bidder can withdraw their deposit.
    function revealBid(bytes32 nonce) public payable{
        // TODO: place your code here
        require(time() >= biddingDeadline);
        require(time() < revealDeadline);

        require(msg.value >= minimumPrice);

        bytes32 checkCommitment = keccak256(abi.encodePacked(msg.value, nonce));
        require(checkCommitment == commitment[msg.sender]);

        authorizedWithdraw[msg.sender] = bidDepositAmount;

        if (msg.value >= HighestPrice){
            secondHighestPrice = HighestPrice;
            if (currentHighestBidder != address(0)){
                authorizedWithdraw[currentHighestBidder] += HighestPrice;
            }
            HighestPrice = msg.value;
            currentHighestBidder = msg.sender;

        } else{
            if (msg.value >= secondHighestPrice){
                secondHighestPrice = msg.value;
            }
            authorizedWithdraw[msg.sender] += msg.value;
        }




    }

    // Need to override the default implementation
    function getWinner() public override view returns (address winner){
        // TODO: place your code here
        require(time() >= auctionEnd);

        winner = currentHighestBidder;
        return winner;      
        
    }

    // finalize() must be extended here to provide a refund to the winner
    // based on the final sale price (the second highest bid, or reserve price).
    function finalize() public override {
        // TODO: place your code here
        require(time() >= auctionEnd);
        require(HighestPrice != 0 && secondHighestPrice != 0 );

        winnerAddress = currentHighestBidder;
        uint partialRefund = HighestPrice - secondHighestPrice;
        HighestPrice = 0;
        secondHighestPrice = 0;
        authorizedWithdraw[winnerAddress] += partialRefund;
        
        // call the general finalize() logic
        super.finalize();
        
    }
}
