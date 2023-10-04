// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { ERC20 } from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    uint256 private constant s_max_Token_Balance = 1000000000 ether; // 10,000,000,000,000,000,000 TT (1 TT = 0.001 ETH)
    uint256 private constant s_tokenTimeLocked = 3600;
    uint256 private immutable s_tokenLiveTime;
    error tokenStillLocked();
    error tokenBalanceExceed();

    constructor(uint256 _initialSupply) ERC20("TaskToken", "TT") {
        _mint(msg.sender, _initialSupply);
        s_tokenLiveTime = block.timestamp;
    }

    function getTokenLiveTime() public view returns (uint256) {
        return s_tokenLiveTime;
    }

    function getTokenTimeLocked() public pure returns (uint256) {
        return s_tokenTimeLocked;
    }

    // Convert TT to ETH
    function TTtoETH(uint256 ttAmount) public pure returns (uint256) {
        return ttAmount * 1e12; // 1 TT = 0.001 ETH (1e12 wei)
    }

    // Convert ETH to TT
    function ETHtoTT(uint256 ethAmount) public pure returns (uint256) {
        return ethAmount / 1e12; // 1 TT = 0.001 ETH (1e12 wei)
    }
}
