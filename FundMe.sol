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

    address public owner;

    // function immediately called when we deploy the contract
    // its called in the same transaction that deploys the contract
    constructor() {
        owner = msg.sender; // set the owner address to our address (since we are the ones deploying the contract, msg.sender will be our address)
    }

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
        
        // only the owner of the contract can withdraw the funds
        require(msg.sender == owner, "Must be owner");
        
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

        // SENDING ETH FROM THE CONTRACT
        // 3 methods are possible: transfer, send and call

        // transfer
        // => deprecated soon
        // transfer is capped at 2300 gas and errors out if it has to spend more (and therefor reverses the transaction)
        // as a reminder, it costs roughly 2100 gas to send eth from one address to another 
        // whoever calls this function will withdraw the funds (msg.sender)
        // we have to cast msg.sender into a payable address
        // then we call transfer
        // we pass the whole contract balance with address(this).balance
        
        // payable(msg.sender).transfer(address(this).balance); 

        // send
        //  => deprecated
        // it also has the 2300 gas limit, but it wont error out. Instead it returns a boolean, true if transfer was successful, false otherwise
        // if it fails, the contract wouldnt revert the transaction and continue execution
        
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");

        // call
        // the one to use
        // no gas limit
        // returns bools for success/failure
        // call is very powerful, we can call any function on the blockchain with it
        // here we use it to send a transaction, so we use the value field of an eth transaction
        // and we give it the whole contract balance
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");

    }

}