// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/Counters.sol";

// make things ownable

interface IERC721 {
    function transferFrom(
        address _from,
        address _to,
        uint _nftId
    ) external;
}

contract DutchAuctioneer {
    using Counters for Counters.Counter;
    Counters.Counter private _auctionNumber;

    constructor() {
        // _auctionNumber is initialized to 1, since 0 == higher gas
        _auctionNumber.increment();
    }
    
    struct Auction {
        uint auctionNumber;
        uint hoursToRun;
        uint endTime;
        uint startingPrice;
        uint reservePrice;
        uint discountRate;
        uint nftId;
        address nftAddress;
        bool active;
    }

    mapping(uint => Auction) auctionRecords;

    event NewAuctionStarted(uint auctionNum, uint startingPrice, nftAddress);

    function startAuction(
        uint _duration,
        uint _startingPrice,
        uint _reservePrice,
        uint _discountRate,
        uint _nftId,
        address _nftAddress
    ) external {
        // requires
        Auction newAuction = Auction({
            auctionNumber: _auctionNumber.current(),
            hoursToRun: _duration*60*60,
            endTime: block.timestamp + duration*60*60,
            startingPrice: _startingPrice,
            reservePrice: _reservePrice,
            discountRate: _discountRate,
            nftId: _nftId,
            nftAddress: _nftAddress,
            active: true
        });

        auctionRecords[_auctionNumber.current()] = newAuction;
        emit NewAuctionStarted(auctionNumber.current(), startingPrice, _nftAddress);
        _auctionNumber.increment();
    }

    function getPrice() public {}

    function buy() {}

    function endAuction() {}
}