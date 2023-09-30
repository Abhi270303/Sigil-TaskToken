// contracts/OurToken.sol
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {Script} from "lib/forge-std/src/Script.sol";
import {myToken} from "../src/myToken.sol";

contract DeploymyToken is Script{

    uint256 public constant INITIAL_SUPPLY = 10000000 ether;

    function run() external returns(myToken){
        vm.startBroadcast();
        myToken mytoken =  new myToken(INITIAL_SUPPLY);
        vm.stopBroadcast();
        return mytoken;
    }

}
