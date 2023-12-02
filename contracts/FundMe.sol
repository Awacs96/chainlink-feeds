// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

error FundMe__NotOwner();

contract FundMe {

    using PriceConverter for uint;

    uint public constant MINIMUM_USD = 50 * 1 ether;
    address public immutable i_owner;
    address[] private s_funders;
    mapping(address => uint) private s_addressToFundedAmount;
    AggregatorV3Interface private s_priceFeed;

    modifier onlyOwner() {
        if ( msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    constructor(address _priceFeed) {
        s_priceFeed = AggregatorV3Interface(_priceFeed);
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "Insufficient amount of ETH provided.");

        s_funders.push(msg.sender);
        s_addressToFundedAmount[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (uint i; i < s_funders.length; i++) {
            address funder = s_funders[i];
            s_addressToFundedAmount[funder] = 0;
        }

        s_funders = new address[](0);
        (bool sent, ) = payable(i_owner).call{ value: address(this).balance }("");
        require(sent, "The transaction failed.");
    }

    function getAddressToAmountFunded(address _funder) public view returns(uint) {
        return s_addressToFundedAmount[_funder];
    }

    function getVersion() public view returns(uint) {
        return s_priceFeed.version();
    }

    function getFunder(uint _index) public view returns(address) {
        return s_funders[_index];
    }

    function getOwner() public view returns(address) {
        return i_owner;
    }

    function getPriceFeed() public view returns(AggregatorV3Interface) {
        return s_priceFeed;
    }

}
