// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

contract FundMe {

    // allows us to call the functions of PriceConverter from uint256, like msg.value.getEthConversionRate()
    // the uint256 is passed as the first argument
    using PriceConverter for uint256; 


    // the minimum amount in USD we want to require for calling the fund function
    // we have to add 18 zeros to it because solidity doesnt have floating numbers and speaks in wei, where 1 ETH = 1 * 1e18
    // so 5 dollars is represented as 5000000000000000000 which is equivalent to $5.000000000000000000, so 18 decimals
    uint256  public minimumUSD = 5 * 1e18; // can also be 5e18

    // array of addresses that sent us money
    // We are just reserving a "parking spot" in the contract's permanent storage.
    // Because it's just a reservation, it defaults to an empty array (length 0). 
    // We don't need the 'new' keyword or a size because we aren't physically 
    // allocating a chunk of memory yet.
    address[] public funders;

    // key is an address, value is how much this address funded the contract (since the last withdrawal)
    mapping(address funder => uint256 amountFunded) public addresssToAmountFunded;


    // payable function
    // you can send eth to this function to fund the smart contract
    function fund() public payable { 

        // require a minimum of <minimumUsd> to be sent
        // unlike in the previous commit where we required 1 ETH, here we require a dollar amount
        // Therefore we will need to call an oracle to get the spot price of ethereum in ETH
        // That way we can require a minimum amount of ETH that matches minimumUSD
        require(msg.value.getConversionRate() >= minimumUSD, "You must sent at least $5."); // This is allowd because we did using PriceConverter for uint256;  
        funders.push(msg.sender); // store the address of the sender to the array
        addresssToAmountFunded[msg.sender] += msg.value; // store the amount sent by the sender
    }

    // withdraw funds and reset the funders array and mapping addresssToAmountFunded
    function withdraw() public {
        // reset the mapping
        for (uint256 funderIndex; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addresssToAmountFunded[funder] = 0;
        }

        // reset the array
        // To wipe the array clean, we build a brand new array and overwrite the old one.
        // The 'new' keyword tells Solidity: "Allocate a new chunk of memory right now."
        // THE RULE: When using 'new' to build an array in memory, Solidity absolutely 
        // requires us to tell it the exact starting size. 
        // So, '(0)' explicitly means "make this brand new array exactly zero items long."
        funders = new address[](0);
    }

}