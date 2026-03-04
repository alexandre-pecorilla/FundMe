// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

// Import the AggregatorV3Interface from Chainlink.
// This acts as a 'Solidity-native ABI': it provides the compiler with the function signatures 
// and return types necessary to interact with the external Chainlink Price Feed contract.
// Without this definition, our contract wouldn't know how to format the call to the 
// external address or how to decode the data sent back.
// The Interface is to the EVM compiler what the ABI is to the frontend application
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract FundMe {

    uint256  public minimumUSD = 5; // the minimum amount in USD we want to require for calling the fund function

    // payable function
    // you can send eth to this function to fund the smart contract
    function fund() public payable { 

        // require a minimum of <minimumUsd> to be sent
        // unlike in the previous commit where we required 1 ETH, here we require a dollar amount
        // Therefore we will need to call an oracle to get the spot price of ethereum in ETH
        // That way we can require a minimum amount of ETH that matches minimumUSD
        require(msg.value >= minimumUSD, "You must sent at least 1 ETH.");
    }

    // function to fetch the live price of ethereum from the Chainlink Sepolia reference contract
    function getEthPrice() public view returns (uint256) {

        // Wrap the sepolia contract address in the Interface so we can make calls
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);

        // Call for the latest price
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price);
    }
}