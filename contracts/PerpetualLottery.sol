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

    // uint public ticketPrice = 100000000000000;
    // uint public numTickets = 500;
    uint public ticketPrice;
    uint public numTickets;
    uint public ticketsInCirculation = 0;
    uint public maxTicketsPerWallet;
    uint public startTime;
    uint public fee = 10000000000000;
    uint raffleNumber = 0;
    bool raffleActive = false;

    // Possibly remove the nested mappings to have this only record the current lotto
    // maps raffleNumber -> adress -> number of tickets
    mapping(uint => mapping(address => uint)) numTicketsHeld;
    // maps raffleNumber -> ticketNumber -> owner address
    mapping(uint => mapping(uint => address)) ticketOwner;

    event LottoStarted(uint ticketPrice, uint numTickets);
    event LottoEnded(uint winningTicketNumber, address indexed winningAddress);

    // onlyOwner
    function startLotto(uint _ticketPrice, uint _numTickets) external {
        require(lottoActive == false, "There is already an active lottery");
        // wording could be better here
        require(_numTickets % 20 == 0, "Number of tickets mod 20 must equal 0");

        raffleActive = true;
        ticketPrice = _ticketPrice;
        numTickets = _numTickets;
        maxTicketsPerWallet = _numTickets / 20;
        startTime = block.timestamp;
        raffleNumber++;

        emit LottoStarted(_ticketPrice, _numTickets);
    }

    function buyTicket(uint _amount, uint _numToBuy) external {
        require(_numToBuy <= numTickets - ticketsInCirculation, "There aren't that many tickets available");
        // require user cant have more than max tickets
        require(numTicketsHeld[raffleNumber][msg.sender] + _numToBuy < maxTicketsPerWallet, "You can't own that many tickets");
        // require number of tickets are available
        // require amount >= ticketprice + fee * num tickets

        // add to mappings
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