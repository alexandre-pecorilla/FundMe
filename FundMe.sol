// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract FundMe {

    // payable function
    // you can send eth to this function to fund the smart contract
    function fund() public payable { 

        // require a minimum of 1 ETH to be sent
        // msg.value contains the amount of token that was sent in the transaction
        // 1e18 = 1 ETH (because 1 ETH is 1000000000000000000 Wei)
        require(msg.value >= 1e18, "You must sent at least 1 ETH.");
    }
}