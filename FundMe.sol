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
    address[] public funders;

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


}