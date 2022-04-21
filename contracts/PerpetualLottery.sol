// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title PerpetualLottery
 * @author delafields
 * @notice This creates a raffle that runs in perpetuity
 * @dev this is purely experimental
 */
contract PerpetualLottery {

    uint public pot = 0;
    uint public ticketPrice = 100000000000000;
    uint public houseFee    = 10000000000000;
    uint public numTickets = 100;
    uint public ticketsInCirculation = 0;
    uint public currentTicketIndex = 0;
    uint public maxTicketsPerWallet = numTickets % 10; // 10% of circ
    uint public startTime;
    uint raffleNumber = 0;
    bool raffleActive = false;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // maps raffleNumber + address -> number of tickets owned
    mapping(uint => mapping(address => uint)) numTicketsHeld;
    // maps raffleNumber + ticketNumber -> owner address
    mapping(uint => mapping(uint => address)) ticketOwner;

    event RaffleStarted(uint raffleNumber);
    event RaffleEnded(uint indexed winningTicketNumber, address indexed winningAddress);
    event TicketsBought(address indexed buyer, uint numTicketsBought, uint numTicketsInCirculation, uint numTicketsLeft);

    //@dev simple onlyOwner mod
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    //@notice this starts a new raffle
    //@dev this must be called once upon deployment, after which it runs in perpetuity
    function startRaffle() external onlyOwner {
        require(raffleActive == false, "There is already an active raffle");

        raffleActive = true;
        startTime = block.timestamp;
        raffleNumber++;

        emit RaffleStarted(raffleNumber);
    }

    //@notice handles the ticket buying functionality
    //@dev possible improvements could be made on amount handling
    //@param _amount eth required to buy tickets
    //@param _numToBuy number of tickets trying to be bought
    function buyTicket(uint _amount, uint _numToBuy) external payable {
        require(_numToBuy <= numTickets - ticketsInCirculation, "You're trying to buy more tickets than are available");
        require(numTicketsHeld[raffleNumber][msg.sender] + _numToBuy <= maxTicketsPerWallet, "You can only own 10% of the tickets, max");
        require(_amount >= (ticketPrice * _numToBuy) + houseFee, "Not paying enough for this number of tickets + the house fee");
        require(msg.value == _amount);

        // log number of tickets in circulation
        ticketsInCirculation += _numToBuy;

        // log number of tickets owned
        numTicketsHeld[raffleNumber][msg.sender] += _numToBuy;
        // map ticket number to its owner
        for (uint i = currentTicketIndex; i < currentTicketIndex + _numToBuy; i++) {
            ticketOwner[raffleNumber][i] = msg.sender;
            currentTicketIndex++;
        }

        // add eth to the pot
        pot += _amount;

        emit TicketsBought(msg.sender, _numToBuy, ticketsInCirculation, numTickets - ticketsInCirculation);

        // if every ticket has been bought, end raffle and kick off a new one
        if (currentTicketIndex == numTickets) {
            this.endRaffle();
        }
    }

    //@notice chooses a winning ticket, pays out owner, kicks off a new lotto
    //@dev this is "blockchain random", could use an oracle
    function endRaffle() external onlyOwner {
        // lil baby check to make sure this isn't ddos'ed
        require(block.timestamp >= startTime + 1 minutes, "This raffle just started!");

        uint winningTicketIndex = getRandomNumber();
        address winnerAddress = ticketOwner[raffleNumber][winningTicketIndex];

        // pay out the owner of the winning ticket
        payable(winnerAddress).transfer(pot);
        pot = 0;

        // start a new raffle
        raffleActive = false;
        ticketsInCirculation = 0;
        currentTicketIndex = 0;

        emit RaffleEnded(winningTicketIndex, winnerAddress);

        this.startRaffle();
    }

    //@dev keccak "random" number generator
    function getRandomNumber() internal view returns (uint randomNumber) {
        /** chainlink VRF if I'm ever feelin' fancy:
        * https://dapp-world.com/smartbook/how-to-get-random-number-in-chainlink-wgJy
        * https://stackoverflow.com/questions/48848948/how-to-generate-a-random-number-in-solidity
        **/

        // grab a random ticket from those in circulation
        uint kecHash = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, currentTicketIndex)));
        return kecHash % currentTicketIndex;
    }

    // fallback triggered by ticket buying
    receive() external payable { }
}