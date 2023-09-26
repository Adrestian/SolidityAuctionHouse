// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Timer.sol";

contract Auction {

    address internal judgeAddress;
    address internal timerAddress;
    address internal sellerAddress;
    address internal winnerAddress;
    uint winningPrice;

    // TODO: place your code here
    mapping (address => uint) internal authorizedWithdraw;
    //address [] bidders;
    address internal currentHighestBidder;
    uint internal currentPrice;
    uint internal auctionEnd;
    bool internal finalizeToSeller = false;
    bool internal refundToWinner = false;

    
    

    // constructor
    constructor(address _sellerAddress,
                     address _judgeAddress,
                     address _timerAddress) {

        judgeAddress = _judgeAddress;
        timerAddress = _timerAddress;
        sellerAddress = _sellerAddress;
        if (sellerAddress == address(0))
          sellerAddress = msg.sender;
    }

    // This is provided for testing
    // You should use this instead of block.number directly
    // You should not modify this function.
    function time() public view returns (uint) {
        if (timerAddress != address(0))
          return Timer(timerAddress).getTime();

        return block.number;
    }

    function getWinner() public view virtual returns (address winner) {
        return winnerAddress;
    }

    function getWinningPrice() public view returns (uint price) {
        return winningPrice;
    }

    // If no judge is specified, anybody can call this.
    // If a judge is specified, then only the judge or winning bidder may call.
    function finalize() public virtual {
        // TODO: place your code here
        require(winnerAddress != address(0));
        require(judgeAddress == address(0) || msg.sender == judgeAddress || msg.sender == winnerAddress);

        if (time() > auctionEnd){
            finalizeToSeller = true;
            withdraw();
        }  
    }

    // This can ONLY be called by seller or the judge (if a judge exists).
    // Money should only be refunded to the winner.
    function refund() public {
        // TODO: place your code here
        require(winnerAddress != address(0));
        require(msg.sender == sellerAddress || msg.sender == judgeAddress);

        if (time() > auctionEnd){
            refundToWinner = true;
            withdraw();
        }
    }

    // Withdraw funds from the contract.
    // If called, all funds available to the caller should be refunded.
    // This should be the *only* place the contract ever transfers funds out.
    // Ensure that your withdrawal functionality is not vulnerable to
    // re-entrancy or unchecked-spend vulnerabilities.
    function withdraw() public {
        //TODO: place your code here

        if (finalizeToSeller || refundToWinner){
            uint amount = winningPrice;
            winningPrice = 0;
            if (finalizeToSeller){
                finalizeToSeller = false;
                payable(sellerAddress).transfer(amount);
            } else{
                refundToWinner = false;
                payable(winnerAddress).transfer(amount);
            }
        } else {
            if (authorizedWithdraw[msg.sender] > 0){
                    uint amount = authorizedWithdraw[msg.sender];
                    authorizedWithdraw[msg.sender] = 0;
                    payable(msg.sender).transfer(amount);
            }             
        }


    }
}
