// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Auction.sol";

contract EnglishAuction is Auction {

    uint public initialPrice;
    uint public biddingPeriod;
    uint public minimumPriceIncrement;

    // TODO: place your code here
    uint public auctionStart;

    // constructor
    constructor(address _sellerAddress,
                          address _judgeAddress,
                          address _timerAddress,
                          uint _initialPrice,
                          uint _biddingPeriod,
                          uint _minimumPriceIncrement)
             Auction (_sellerAddress, _judgeAddress, _timerAddress) {

        initialPrice = _initialPrice;
        biddingPeriod = _biddingPeriod;
        minimumPriceIncrement = _minimumPriceIncrement;

        // TODO: place your code here
        auctionStart = time();
        auctionEnd = auctionStart + biddingPeriod;
        currentPrice = initialPrice - _minimumPriceIncrement;
    }

    function bid() public payable{
        // TODO: place your code here
        require(time() < auctionEnd);

        require(msg.value >= currentPrice + minimumPriceIncrement);
        
        if(currentHighestBidder != address(0)){
            authorizedWithdraw[currentHighestBidder] += currentPrice;
        }

        // bids[msg.sender] = msg.value;
        auctionEnd = time() + biddingPeriod;
        currentHighestBidder = msg.sender;
        currentPrice = msg.value;
    }

    // Need to override the default implementation
    function getWinner() public override view returns (address winner){
        if (time() >= auctionEnd){
            return currentHighestBidder;
        }
        // TODO: place your code here
    }
}
