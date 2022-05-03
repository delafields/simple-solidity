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
 * @title English Auction
 * @author delafields
 * @notice This allows an nft owner to initiate an english auction for their nft
 * @dev this is purely experimental
 */
contract EnglishAuction {

    IERC721 public immutable nft;

    ///** STATE **///
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

    /**
    * @param _startingPrice Price at which the auction begins
    * @param _reservePrice  Minumum required price for sale
    * @param _nftId Unique identifier of the NFT
    * @param _nftAddress Address of the NFT
    */ 
    constructor(
        uint _startingPrice,
        uint _reservePrice,
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

    ///** MODIFIERS **///
    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can call this");
        _;
    }

    // maps a bidder to their bid amount
    mapping(address => uint) public bids;


    ///** EVENTS **///
    event Bid(uint amount, address indexed sender);
    event WithdrawBid(uint amount, address indexed bidder);
    event EndAuction(uint highestBid, address indexed highestBidder);

    /**
    * @dev Handles bidding logic. Fails if auction is over or amount sent < highest bid
    * @dev Adds to a bidders balance if they're placing more money
    */
    function bid() external payable {
        require(block.timestamp < endTime, "Auction has expired");
        require(msg.value > highestBid, "The amount sent was less than the current highest bid");

        bids[msg.sender] += msg.value;
        highestBidder = msg.sender;

        emit Bid(msg.value, msg.sender);
    }

    /**
    * @dev Allows a bidder to withdraw their bid amount
    * @dev Fails if sender has not made a bid
    */
    function withdrawCurrentBid() external {
        require(bids[msg.sender] >= 0, "Trying to withdraw without having made any bids");

        uint balance = bids[msg.sender];
        bids[msg.sender] = 0;
        payable(msg.sender).transfer(balance);

        emit WithdrawBid(balance, msg.sender);
    }

    /**
    * @dev Allows for the owner to end the auction
    *      This transfers the nft and sends all remaining funds 
    *      to the contract owner (this may not be a true english auction)
    * @dev Fails if the auction has not yet ended
    */
    function end() external onlyOwner {
        require(block.timestamp >= endTime, "Auction isn't over");

        // require that someone has actually made a bid
        if (highestBidder != address(0)) {
            nft.transferFrom(nftSeller, highestBidder, nftId);
            nftSeller.transfer(highestBid);
            selfdestruct(nftSeller);
        }

        emit EndAuction(highestBid, highestBidder);
    }
}