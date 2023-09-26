// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Auction.sol";

contract DutchAuction is Auction {

    uint public initialPrice;
    uint public biddingPeriod;
    uint public offerPriceDecrement;

    // TODO: place your code here
    uint public auctionStart;
    bool public bidEnd;

    // constructor
    constructor(address _sellerAddress,
                          address _judgeAddress,
                          address _timerAddress,
                          uint _initialPrice,
                          uint _biddingPeriod,
                          uint _offerPriceDecrement)
             Auction (_sellerAddress, _judgeAddress, _timerAddress) {

        initialPrice = _initialPrice;
        biddingPeriod = _biddingPeriod;
        offerPriceDecrement = _offerPriceDecrement;

        // TODO: place your code here
        auctionStart = time();
        auctionEnd = auctionStart + biddingPeriod;
        bidEnd = false;

    }


    function bid() public payable{
        // TODO: place your code here
        require(!bidEnd);
        require(time() < auctionEnd);
        uint currentPrice = initialPrice-(time()-auctionStart)*offerPriceDecrement;
        require(msg.value >= currentPrice);

        bidEnd = true;
        // bids[msg.sender] = currentPrice;
        winningPrice = currentPrice;
        winnerAddress = msg.sender;
        if (msg.value > currentPrice){
            payable(msg.sender).transfer(msg.value-currentPrice);
        }
    }

}
