// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {myToken} from "../src/myToken.sol";
import {DeploymyToken} from "../script/DeploymyToken.sol";
import {Script} from "../lib/forge-std/src/Script.sol";

contract CounterTest is Test{

    myToken public mytoken;
    DeploymyToken public deployToken;

    uint256 public constant PLAYER_BALANCE = 10;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 private constant s_tokenTimeLocked = 3600;

    function setUp() public {
        deployToken = new DeploymyToken();
        mytoken = deployToken.run();
    }

    function testTransferShouldFailWhenEnoughTimeHasNotPassed() public{
        // Arrange
        vm.prank(msg.sender);

        // Act+ Assert
        vm.expectRevert(myToken.tokenStillLocked.selector);
        mytoken.transfer(bob,PLAYER_BALANCE);
    }

    function testTransferShouldFailWhenTokenAmountBecomesMoreThanLimit() public{

        // Arrange
        vm.warp(mytoken.getTokenTimeLocked()+block.timestamp);

        // Act
        vm.expectRevert(myToken.tokenBalanceExceed.selector);
        vm.prank(msg.sender);
        mytoken.transfer(bob,10001 ether);

        // Assert
        assertEq(mytoken.balanceOf(bob),0);
    }

    function testTransferShouldSuccedWhenTimeHasPassedAndTokensAmountIsPerfect() public{

        // Arrange
        vm.warp(mytoken.getTokenTimeLocked()+block.timestamp);

        // Act
        vm.prank(msg.sender);
        mytoken.transfer(bob,PLAYER_BALANCE);

        // Assert
        assertEq(mytoken.balanceOf(bob),10);
    }

    function testTransferFromShouldFailWhenEnoughTimeHasNotPassed() public{
        
        // Arrange
        vm.prank(msg.sender);
        
        // Act
        mytoken.approve(alice, 1000 ether);

        // Assert
        vm.prank(alice);
        console.log(mytoken.balanceOf(msg.sender));
        vm.expectRevert(myToken.tokenStillLocked.selector);
        mytoken.transferFrom(msg.sender,bob,PLAYER_BALANCE);
        assertEq(mytoken.balanceOf(bob),0);
    }

    function testTransferFromShouldFailWhenTokenAmountExceeds() public{
        // Arrange
        vm.prank(msg.sender);
        
        // Act
        mytoken.approve(alice, 100000 ether);

        // Assert
        vm.warp(mytoken.getTokenTimeLocked()+block.timestamp);
        vm.expectRevert(myToken.tokenBalanceExceed.selector);
        vm.prank(alice);
        mytoken.transferFrom(msg.sender,bob,10001 ether);
        assertEq(mytoken.balanceOf(bob),0);
    }

    function testTransferFromShouldSucceedWhenEnoughTimeHasPassedAndTokensAmountIsPerfect() public{
        
        // Arrange
        vm.prank(msg.sender);
        
        // Act
        mytoken.approve(alice, 1000 ether);

        // Assert
        vm.warp(mytoken.getTokenTimeLocked()+block.timestamp);
        vm.prank(alice);
        mytoken.transferFrom(msg.sender,bob,PLAYER_BALANCE);
        assertEq(mytoken.balanceOf(bob),10);
    }

}
