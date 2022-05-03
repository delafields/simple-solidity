// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

interface IERC721 {
    function transferFrom(
        address _from,
        address _to,
        uint _nftId
    ) external;
}

contract EnglishAuction {

    IERC721 public immutable nft;

    uint private constant DURATION = 7 days;
    uint public immutable startingPrice;
    uint public immutable reservePrice;
    uint public immutable startTime;
    uint public immutable endTime;
    uint public highestBid;
    uint public immutable nftId;
    address payable public immutable nftSeller;
    address public highestBidder;
    address private owner = msg.sender;

    mapping(address => uint) public bids;

    event Bid(uint amount, address indexed sender);
    event WithdrawBid(uint amount, address indexed bidder);

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can call this");
        _;
    }

    constructor(
        uint _startingPrice,
        uint _reservePrice;
        uint _nftId,
        address _nftAddress
    ) {

        startingPrice = _startingPrice;
        reservePrice = _reservePrice;
        highestBid = _startingPrice;
        startTime = block.timestamp;
        endTime = block.timestamp + DURATION;
    
        nftId = _nftId;
        nftSeller = payable(msg.sender);
        nft = IERC721(_nftAddress);
    }

    function bid() external payable {
        require(block.timestamp < endTime, "Auction has expired");
        require(msg.value > highestBid, "The amount sent was less than the current highest bid");

        bids[msg.sender] = msg.value;
        highestBidder = msg.sender;

        emit Bid(msg.value, msg.sender);
    }

    function withdrawCurrentBid() external {
        require(bids[msg.sender] >= 0, "Trying to withdraw without having made any bids");

        uint balance = bids[msg.sender];
        bids[msg.sender = 0];
        payable(msg.sender, balance);
    }

    function end() onlyOwner {
        require(block.timestamp >= endTime, "Auction isn't over");

        if (highestBidder != address(0)) {
            nft.transferFrom(nftSeller, highestBidder, nftId);
            nftSeller.transfer(highestBid);
            selfdestruct(owner);
        }
    }
}