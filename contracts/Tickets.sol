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

    struct Ticket {
      uint256 id;
      uint256 buyPrice;
      uint256 askingPrice;
      address owner;
    }

    struct TicketOwned {
      uint256 id;
      uint256 eventId;
    }

    struct Event {
      address artist;
      string eventDate;
      string dueDate;
      uint32 price;
      uint256 amountGathered;
      uint256 amountAim;
      uint32 initialSupply;
      uint256 ticketsSold;
    }
    mapping(uint256 => Event) public eventInfo; // eventInfo[eventId]
    mapping(uint256 => mapping(uint256 => Ticket)) public ticketInfo; // ticketInfo[eventId][ticketId]
    mapping(address => mapping(uint256 => Reseller)) public resellers; // resellers[address][eventId]
    // mapping(address => uint[]) public ownedTickets; // ownedTickets[address] = tuple(eventId, ticketId)
    mapping(address => TicketOwned[]) public ownedTickets; // ownedTickets[address] = tuple(eventId, ticketId)


    function getNextTicketId(uint256 eventId) internal view returns (uint256) {
      return(eventInfo[eventId].ticketsSold + 1);
    }

    function getOwnedTickets() public view returns (TicketOwned[] memory) {
      return ownedTickets[msg.sender];
    }

    modifier artistOnly(uint256 _id) {
        require(eventInfo[_id].artist == msg.sender);
        _;
    }

    event SenderBalance(uint256 balance);

    constructor() ERC1155("") {
        eventCount = 0;
    }

    function createEvent(uint32 initialSupply, uint32 pricePerTicket)
        external
        returns (uint)
    {
        eventCount++;
        uint256 eventId = eventCount;
        _mint(msg.sender, eventId, initialSupply, "");

        eventInfo[eventId].artist = msg.sender;
        eventInfo[eventId].price = pricePerTicket;
        eventInfo[eventId].initialSupply = initialSupply;
        eventInfo[eventId].ticketsSold = 0;
        eventInfo[eventId].amountGathered = 0;
        
        // TODO:
        // eventInfo.eventDate = 
        // eventInfo.dueDate = 
        // eventInfo.amountAim = 
        
        return eventId;
    }
    // For debugging.
    // function getBalance() public returns (uint256) {
    //   return msg.sender.balance;
    // }
    function ticketPrice(uint256 eventId) external view returns (uint256) {
      return eventInfo[eventId].price;
    }

    function getEventData(uint256 eventId) external view returns (uint256, uint256) {
      return (eventInfo[eventId].ticketsSold, eventInfo[eventId].amountGathered);
    }


    function buyResellTicket(
      address ticketOwner,
      uint256 eventId,
      uint256 ticketId
    ) external payable {
      uint256 askingPrice = ticketInfo[eventId][ticketId].askingPrice;
      require(askingPrice <= msg.value, "Asking price is higher then msg.value");
      
      // if ticket is being resold, the host/artist gets 50% (make this customizable)
      uint256 artistShare = HelperLib.getPercentage(askingPrice, 50);
      uint256 resellerShare = askingPrice - artistShare;

      payable(ticketOwner).transfer(resellerShare);
      payable(eventInfo[eventId].artist).transfer(artistShare);

      _safeTransferFrom(
        ticketOwner,
        msg.sender,
        eventId,
        1, //amountOfTickets
        "test"
      );

      ticketInfo[eventId][ticketId].buyPrice = msg.value;
      ticketInfo[eventId][ticketId].owner = msg.sender;

      eventInfo[eventId].amountGathered += artistShare;


      resellers[ticketOwner][eventId].ticketsForSale -= 1;
      if (resellers[ticketOwner][eventId].ticketsForSale == 0) {
        resellers[ticketOwner][eventId].askingPrice = 0;
      }

      _safeTransferFrom(
            ticketOwner,
            msg.sender,
            eventId,
            1, //amount
            "test"
      );
    }

    function buyTicket(
        uint256 eventId,
        uint256 amountOfTickets
    ) external payable {
      require(msg.sender.balance > msg.value, "msg.sender.balance is less then msg.value");
      require(
          msg.value >= (eventInfo[eventId].price * amountOfTickets),
          "msg.value is less then the accumulated price of tickets"
      );
      require(amountOfTickets <= eventInfo[eventId].initialSupply - eventInfo[eventId].ticketsSold, "not enough tickets available");

      uint256 ticketId = getNextTicketId(eventId);

      payable(eventInfo[eventId].artist).transfer(msg.value);

      _safeTransferFrom(
          eventInfo[eventId].artist,
          msg.sender,
          eventId,
          amountOfTickets,
          "test"
      );

      for(uint i=0; i<amountOfTickets; i++){
        ticketInfo[eventId][ticketId + i].id = ticketId;
        ticketInfo[eventId][ticketId + i].buyPrice = msg.value / amountOfTickets;
        ticketInfo[eventId][ticketId + i].owner = msg.sender;

        ownedTickets[msg.sender].push(TicketOwned(ticketId + i ,eventId));
      }

      eventInfo[eventId].amountGathered += msg.value;
      eventInfo[eventId].ticketsSold += amountOfTickets;
    }

    function addTicketResell(
        uint256 eventId,
        uint256 amountOfTickets,
        uint256 askingPrice
    ) external {
        require(
            balanceOf(msg.sender, eventId) >= amountOfTickets,
            "msg.sender does not own enough tickets"
        );

        // limit to 1 in POC
        resellers[msg.sender][eventId].ticketsForSale = 1;
        resellers[msg.sender][eventId].askingPrice = askingPrice;
    }

    // function cancelTicketResell

    // TODO: URI

}
