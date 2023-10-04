// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { MyToken } from "./MyToken.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract TokenExchange {
    MyToken public myToken;
    address public owner;

    struct Transaction {
        address user;
        uint256 ethAmount;
        uint256 ttAmount;
        uint256 timestamp;
    }

    Transaction[] public buyTransactions;
    Transaction[] public sellTransactions;

    constructor(MyToken _tokenAddress) {
        myToken = _tokenAddress;
        owner = msg.sender;
    }

    // Allow users to buy TT using ETH
    function buyTokens(uint256 ethAmount) public payable {
        require(ethAmount > 0, "Must send ETH to buy TT");
        require(block.timestamp >= myToken.getTokenLiveTime() + myToken.getTokenTimeLocked(), "Token still locked");

        uint256 ttAmount = myToken.ETHtoTT(ethAmount); // Convert ETH to TT
        require(ttAmount <= myToken.balanceOf(address(this)), "Insufficient TT in the contract");

        // Transfer TT from the contract to the buyer
        myToken.transfer(msg.sender, ttAmount);

        // Record the transaction
        buyTransactions.push(Transaction(msg.sender, ethAmount, ttAmount, block.timestamp));
    }

    // Allow users to sell TT for ETH
    function sellTokens(uint256 ttAmount) public {
        require(ttAmount > 0, "Must specify the amount of TT to sell");
        require(block.timestamp >= myToken.getTokenLiveTime() + myToken.getTokenTimeLocked(), "Token still locked");

        uint256 ethAmount = myToken.TTtoETH(ttAmount); // Convert TT to ETH
        require(ethAmount <= address(this).balance, "Insufficient ETH in the contract");

        // Transfer ETH from the contract to the seller
        payable(msg.sender).transfer(ethAmount);

        // Burn TT from the seller's balance
        myToken.transferFrom(msg.sender, address(this), ttAmount);

        // Record the transaction
        sellTransactions.push(Transaction(msg.sender, ethAmount, ttAmount, block.timestamp));
    }

    // Allow the owner to withdraw ETH from the exchange
    function withdrawETH(uint256 ethAmount) public {
        require(msg.sender == owner, "Only the owner can call this function");
        require(ethAmount <= address(this).balance, "Insufficient ETH in the exchange");
        payable(owner).transfer(ethAmount);
    }

    // Allow the owner to withdraw any excess tokens from the exchange
    function withdrawExcessTokens(address tokenAddress, uint256 amount) public {
        require(msg.sender == owner, "Only the owner can call this function");
        require(tokenAddress != address(myToken), "Cannot withdraw TT from this function");
        require(amount > 0, "Withdraw amount must be greater than 0");
        require(IERC20(tokenAddress).balanceOf(address(this)) >= amount, "Insufficient tokens in the contract");
        
        IERC20(tokenAddress).transfer(owner, amount);
    }

    // Get the number of buy transactions
    function getBuyTransactionCount() public view returns (uint256) {
        return buyTransactions.length;
    }

    // Get the number of sell transactions
    function getSellTransactionCount() public view returns (uint256) {
        return sellTransactions.length;
    }
}
