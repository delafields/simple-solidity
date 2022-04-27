// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

interface IERC721 {
    function transferFrom(
        address _from,
        address _to,
        uint _nftId
    ) external;
}

contract DutchAuctioneer {

    function startAuction() {}

    function getPrice() {}

    function buy() {}

    function endAuction() {}
}