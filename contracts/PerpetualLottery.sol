// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

    /** implementation notes
    * must be able to trigger the start of a lotto
    * must be able to track the number of tickets bought
    * must have max tickets per user
    * must be able to trigger the end of a lotto (block time)
    **/

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract Lotto {

    // TODO: do I add all of these to the constructor?
    uint public pot = 0;
    uint public ticketPrice;
    uint public numTickets;
    uint public ticketsInCirculation = 0;
    uint public maxTicketsPerWallet;
    uint public startTime;
    uint public houseFee = 10000000000000;
    uint raffleNumber = 0;
    bool raffleActive = false;

    // Possibly remove the nested mappings to have this only record the current lotto
    // or keep...so that I can delete once the next raffle starts
    // TODO: rename numTicketsHeld
    // maps raffleNumber -> adress -> number of tickets
    mapping(uint => mapping(address => uint)) numTicketsHeld;
    // maps raffleNumber -> ticketNumber -> owner address
    mapping(uint => mapping(uint => address)) ticketOwner;

    // do I need indexed?
    event LottoStarted(uint ticketPrice, uint numTickets);
    event LottoEnded(uint winningTicketNumber, address indexed winningAddress);
    event TicketsBought(address indexed buyer, uint numTicketsBought, uint numTicketsInCirculation, uint numTicketsLeft);

    // onlyOwner
    function startLotto(uint _ticketPrice, uint _numTickets) external {
        // TODO: keep _ticketPrice within a certain bound or hardcode it, same with ticketCount
        // uint public ticketPrice = 100000000000000;
        // uint public numTickets = 500;

        require(raffleActive == false, "There is already an active lottery");
        // wording could be better here
        require(_numTickets % 20 == 0, "Number of tickets must be a factor of 20");

        raffleActive = true;
        ticketPrice = _ticketPrice;
        numTickets = _numTickets;
        maxTicketsPerWallet = _numTickets / 20;
        startTime = block.timestamp;
        raffleNumber++;

        emit LottoStarted(_ticketPrice, _numTickets);
    }

    function buyTicket(uint _amount, uint _numToBuy) external {
        // require number of tickets are available
        require(_numToBuy <= numTickets - ticketsInCirculation, "You're trying to buy more tickets than are available");
        // require user cant have more than max tickets
        require(numTicketsHeld[raffleNumber][msg.sender] + _numToBuy < maxTicketsPerWallet, "You can only own 5% of the tickets, max");
        // require amount >= ticketprice + fee * num tickets
        require(_amount >= (ticketPrice * _numToBuy) + houseFee, "Not paying enough for this number of tickets, + the house fee");

        ticketsInCirculation -= _numToBuy;
        numTicketsHeld[raffleNumber][msg.sender] += _numToBuy;
        // TODO: need to completely change how this works
            // Can you buy more than 1 at once? If so how do I make this mapping for multiple tickets?
        // ticketOwner[raffleNumber][]

        // TODO: make sure that this is actually transferring ether
        pot += amount;

        event TicketsBought(address indexed buyer, uint numTicketsBought, uint numTicketsInCirculation, uint numTicketsLeft);


        emit TicketsBought(msg.sender, _numToBuy, ticketsInCirculation, numTickets - ticketsInCirculation);
    }

    // onlyOwner
    // blocktime: https://ethereum.stackexchange.com/questions/7853/is-the-block-timestamp-value-in-solidity-seconds-or-milliseconds
    function endLotto() external {
        // uint internal winningTicketNumber = getRandomNumber(_numTickets);
        // address internal winningTicketOwner = 
        // lottoNumber++;
    }

    // chainlink VRF
    // https://dapp-world.com/smartbook/how-to-get-random-number-in-chainlink-wgJy
    function getRandomNumber() internal returns (uint randomNumber) {}

    // uint256 number;

    // /**
    //  * @dev Store value in variable
    //  * @param num value to store
    //  */
    // function store(uint256 num) public {
    //     number = num;
    // }

    // /**
    //  * @dev Return value 
    //  * @return value of 'number'
    //  */
    // function retrieve() public view returns (uint256){
    //     return number;
    // }
}