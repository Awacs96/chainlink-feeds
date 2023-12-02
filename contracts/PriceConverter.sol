// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {

    function getPrice(AggregatorV3Interface _priceFeed) internal view returns(uint) {
        (, int answer, , , ) = _priceFeed.latestRoundData();

        // Answer has 8 decimals, ETH has 18 decimals => 10e10 to have the same units
        return uint(answer * 10e10);
    }

    function getConversionRate(uint ethAmount, AggregatorV3Interface _priceFeed) internal view returns(uint) {
        uint ethPrice = getPrice(_priceFeed);
        uint ethAmountInUsd = ( ethPrice * ethAmount ) / 1 ether;
        return ethAmountInUsd;
    }

}
