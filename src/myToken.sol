// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {ERC20} from "@openzepplin/token/ERC20/ERC20.sol";
import {Test, console} from "forge-std/Test.sol";

contract myToken is ERC20{

    uint256 private constant s_max_Token_Balance = 10000 ether;

    uint256 private constant s_tokenTimeLocked = 3600;

    uint256 private immutable s_tokenLiveTime;

    error tokenStillLocked();
    error tokenBalanceExceed();

    mapping(address => uint256) public _balances;

    constructor(uint256 _inititalSupply) ERC20("TaskToken","TT"){
        _mint(msg.sender,_inititalSupply);
        s_tokenLiveTime = block.timestamp;
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        if(block.timestamp<s_tokenLiveTime+s_tokenTimeLocked){
            revert tokenStillLocked();
        }
        if(balanceOf(to)+amount>s_max_Token_Balance){
            revert tokenBalanceExceed();
        }
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public  override returns (bool) {
         if(block.timestamp<s_tokenLiveTime+s_tokenTimeLocked){
            revert tokenStillLocked();
        }
        if(balanceOf(to)+amount>s_max_Token_Balance){
            revert tokenBalanceExceed();
        }
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function getMaxTokeBalance() external view returns(uint256){
        return s_max_Token_Balance;
    }

    function getTokenTimeLocked() external view returns(uint256){
        return s_tokenTimeLocked;
    }

    function getTokenLiveTime() external view returns(uint256){
        return s_tokenLiveTime;
    }

}
