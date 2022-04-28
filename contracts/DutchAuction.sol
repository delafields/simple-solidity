// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


interface IERC721 {
    function transferFrom(
        address _from,
        address _to,
        uint _nftId
    ) external;
}

/**
 * @title Dutch Auction
 * @author delafields
 * @notice This allows an nft owner to initiate a dutch auction for their nft
 * @dev this is purely experimental
 */
contract DutchAuction {

    IERC721 public immutable nft;

    uint private constant DURATION = 7 days;
    uint public immutable startingPrice;
    uint public immutable reservePrice;
    uint public immutable discountRate;
    uint public immutable startTime;
    uint public immutable endTime;
    uint public immutable nftId;
    address payable public immutable nftSeller;

    /**
    * @param _startingPrice High point price of NFT
    * @param _reservePrice  Low point price of NFT
    * @param _discountRate Rate at which the _startingPrice degrades over time
    * @param _nftId Unique identifier of the NFT
    * @param _nftAddress Address of the NFT
    */
    constructor(
        uint _startingPrice,
        uint _reservePrice,
        uint _discountRate,
        uint _nftId,
        address _nftAddress
    )
        payable
    {
        // Price must be degradeable via this simple formula
        require(_startingPrice >= _discountRate * DURATION, "Price must be >= discount rate * duration (7 days)");
        
        startingPrice = _startingPrice;
        reservePrice  = _reservePrice;
        discountRate = _discountRate;
        startTime = block.timestamp;
        endTime = block.timestamp + DURATION;
        nftId = _nftId;
        nftSeller = payable(msg.sender);

        nft = IERC721(_nftAddress);

    }

    /**
    * @returns _currentPrice Price as a function of time since start
    */
    function getCurrentPrice() public view returns (uint _currentPrice) {
        uint timeFromStart = block.timestamp - startTime;
        // discount is a function of time & discount rate
        uint dutchDiscount = discountRate * timeFromStart;
        uint currentPrice = startingPrice - dutchDiscount;

        return currentPrice;
    }

    /**

    */
    function buy() external payable {
        require(block.timestamp < endTime, "Auction has expired");

        uint currentPrice = getCurrentPrice();
        require(currentPrice >= reservePrice, "The natural timed discount of this auction is below reserve.");
        require(msg.value >= currentPrice, "The current price is > the amount of ETH sent");

        nft.transferFrom(nftSeller, msg.sender, nftId);

        uint refundAmount = msg.value - currentPrice;
        if (refundAmount > 0) {
            payable(msg.sender).transfer(refundAmount);
        }

        selfdestruct(nftSeller);
    }
}