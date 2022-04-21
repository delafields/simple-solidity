// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract Lotto {

    uint public pot = 0;
    uint public ticketPrice;
    uint public numTickets;
    uint public ticketsInCirculation = 0;
    uint public currentTicketIndex = 0;
    uint public maxTicketsPerWallet;
    uint public startTime;
    uint public houseFee = 10000000000000;
    uint raffleNumber = 0;
    bool raffleActive = false;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // maps raffleNumber + adress -> number of tickets owned
    mapping(uint => mapping(address => uint)) numTicketsHeld;
    // maps raffleNumber + ticketNumber -> owner address
    mapping(uint => mapping(uint => address)) ticketOwner;

    event LottoStarted(uint ticketPrice, uint numTickets);
    event LottoEnded(uint indexed winningTicketNumber, address indexed winningAddress);
    event TicketsBought(address indexed buyer, uint numTicketsBought, uint numTicketsInCirculation, uint numTicketsLeft);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function startLotto(uint _ticketPrice, uint _numTickets) external onlyOwner {
        require(_numTickets >= 100 || _numTickets <= 1000, "Must be between 100 and 1000 tickets");
        require(raffleActive == false, "There is already an active lottery");
        require(_numTickets % 20 == 0, "Number of tickets must be a factor of 20");

        raffleActive = true;
        ticketPrice = _ticketPrice;
        numTickets = _numTickets;
        maxTicketsPerWallet = _numTickets / 20;
        startTime = block.timestamp;
        raffleNumber++;

        emit LottoStarted(_ticketPrice, _numTickets);
    }

    function buyTicket(uint _amount, uint _numToBuy) external payable {
        require(_numToBuy <= numTickets - ticketsInCirculation, "You're trying to buy more tickets than are available");
        require(numTicketsHeld[raffleNumber][msg.sender] + _numToBuy <= maxTicketsPerWallet, "You can only own 5% of the tickets, max");
        require(_amount >= (ticketPrice * _numToBuy) + houseFee, "Not paying enough for this number of tickets, + the house fee");

        ticketsInCirculation -= _numToBuy;
        numTicketsHeld[raffleNumber][msg.sender] += _numToBuy;

        for (uint i = currentTicketIndex; i < currentTicketIndex + _numToBuy; i++) {
            ticketOwner[raffleNumber][i] = msg.sender;
            currentTicketIndex++;
        }

        // TODO: make sure that this is actually transferring ether
        // this probably needs msg.value or something
        pot += _amount;

        emit TicketsBought(msg.sender, _numToBuy, ticketsInCirculation, numTickets - ticketsInCirculation);
    }

    // blocktime: https://ethereum.stackexchange.com/questions/7853/is-the-block-timestamp-value-in-solidity-seconds-or-milliseconds
    function endLotto() external onlyOwner {
        // require block.timestamp > startTime

        uint winningTicketIndex = getRandomNumber();
        address winnerAddress = ticketOwner[raffleNumber][winningTicketIndex];

        address(winnerAddress).transfer(pot);

        raffleActive = false;
        ticketPrice = 0;
        numTickets = 0;
        maxTicketsPerWallet = 0;

        emit LottoEnded(winningTicketIndex, winnerAddress);
    }

    /** chainlink VRF if I'm ever feelin' fancy:
        * https://dapp-world.com/smartbook/how-to-get-random-number-in-chainlink-wgJy
        * https://stackoverflow.com/questions/48848948/how-to-generate-a-random-number-in-solidity
    **/
    function getRandomNumber() internal returns (uint randomNumber) {
        uint kecHash = keccak256(abi.encodePacked(block.difficulty, now, currentTicketIndex));
        return kecHash % currentTicketIndex;
    }
}