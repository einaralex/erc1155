// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

import "./HelperLib.sol";


// For simplicity and also for possible exploitation, a ticket-holder/fan can only resell one ticket at a time.

contract Tickets is ERC1155 {
    uint256 public eventCount;

    struct Reseller {
        uint256 ticketsForSale;
        uint256 askingPrice;
    }

    mapping(uint256 => address) public artist;
    mapping(uint256 => uint256) public ticketPrice;
    mapping(address => mapping(uint256 => Reseller)) public resellers; // resellers[address][eventId]

    modifier artistOnly(uint256 _id) {
        require(artist[_id] == msg.sender);
        _;
    }

    event SenderBalance(uint256 balance);

    constructor() ERC1155("") {
        eventCount = 0;
    }

    function createTicketTokens(uint256 initialSupply, uint256 pricePerTicket)
        external
        returns (uint)
    {
        eventCount++;
        uint256 eventId = eventCount;
        artist[eventId] = msg.sender;
        _mint(msg.sender, eventId, initialSupply, "");
        ticketPrice[eventId] = pricePerTicket;
        
        return eventId;
    }
    function getBalance() public returns (uint256) {
      emit SenderBalance(msg.sender.balance);
      return msg.sender.balance;
    }
    function buyTicketToken(
        address ticketOwner,
        uint256 amountOfTickets,
        uint256 eventId
    ) external payable {
        emit SenderBalance(msg.sender.balance);
        require(msg.sender.balance > msg.value, "You do not afford this");
        require(
            msg.value >= (ticketPrice[eventId] * amountOfTickets),
            "Not sufficient funds"
        );
        if (ticketOwner == artist[eventId]) {
            payable(ticketOwner).transfer(msg.value);
        } else {
            uint256 askingPrice = resellers[ticketOwner][eventId].askingPrice;
            require(askingPrice <= msg.value, "Asking price is more.");
            require(
                resellers[ticketOwner][eventId].ticketsForSale >=
                    amountOfTickets,
                "Ticket holder doesn't own that many tickets"
            );
            // if ticket is being resold, the host/artist get's 50% (make this customizable)
            uint256 artistShare = HelperLib.getPercentage(askingPrice, 50);
            uint256 resellerShare = askingPrice - artistShare;

            payable(ticketOwner).transfer(resellerShare);
            payable(artist[eventId]).transfer(artistShare);

            resellers[ticketOwner][eventId].askingPrice = 0;
            resellers[ticketOwner][eventId].ticketsForSale -= amountOfTickets;
        }
        //emit Transfer(msg.sender, ticketOwner, ethAmount);

        _safeTransferFrom(
            ticketOwner,
            msg.sender,
            eventId,
            amountOfTickets,
            "test"
        );
    }

    function setForAuction(
        uint256 eventId,
        uint256 amountOfTickets,
        uint256 askingPrice
    ) external {
        require(
            balanceOf(msg.sender, eventId) >= amountOfTickets,
            "You don't own that many tickets"
        );

        resellers[msg.sender][eventId].ticketsForSale = 1;
        resellers[msg.sender][eventId].askingPrice = askingPrice;
    }
}
