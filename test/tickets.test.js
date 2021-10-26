const Tickets = artifacts.require("Tickets");
const truffleAssert = require("truffle-assertions");

contract("Tickets", (accounts) => {
  let contractInstance;
  let ticketsAvailable = 20;
  let pricePerTicket = 1000;
  let mintedTokensReceipt;
  let eventId;
  let artist = accounts[1];
  let fan = accounts[2];
  let fanNr = (nr) => accounts[nr];
  beforeEach(async () => {
    contractInstance = await Tickets.deployed();
    mintedTokensReceipt = await contractInstance.createEvent(
      ticketsAvailable,
      pricePerTicket,
      {
        from: artist,
      }
    );
    eventId = mintedTokensReceipt.receipt.logs[0].args.id.toString();
    console.log("EventId", (await contractInstance.eventCount()).toString());
  });
  /**
   * MINTING
   */
  it("should mint a new set of tokens", async () => {
    assert.equal(
      await contractInstance.balanceOf(artist, eventId),
      ticketsAvailable
    );
  });
  it("should verify ticketPrice", async () => {
    assert.equal(await contractInstance.ticketPrice(eventId), pricePerTicket);
  });
  /**
   * BUYING A TICKET
   */
  it("should revert if msg.value is not enough for a ticket", async () => {
    await truffleAssert.reverts(
      contractInstance.buyTicket(eventId, 1, {
        from: fan,
        value: 999,
      }),
      "msg.value is less then the accumulated price of tickets"
    );
  });
  it("should allow a fan to buy ticket if msg.value is sufficient.", async () => {
    let ticketsToBuy = 2;
    await contractInstance.buyTicket(eventId, ticketsToBuy, {
      from: fan,
      value: ticketsToBuy * pricePerTicket,
    });

    assert.equal(
      await contractInstance.balanceOf(artist, eventId),
      ticketsAvailable - ticketsToBuy
    );
    assert.equal(await contractInstance.balanceOf(fan, eventId), ticketsToBuy);
  });

  it.only("WIP test ownedTickets", async () => {
    let ticketsToBuy = 2;
    await contractInstance.buyTicket(eventId, ticketsToBuy, {
      from: fan,
      value: ticketsToBuy * pricePerTicket,
    });
    await contractInstance.buyTicket(eventId, ticketsToBuy, {
      from: fan,
      value: ticketsToBuy * pricePerTicket,
    });
    await contractInstance.buyTicket(eventId, ticketsToBuy, {
      from: fanNr(4),
      value: ticketsToBuy * pricePerTicket,
    });
    await contractInstance.buyTicket(eventId, ticketsToBuy, {
      from: fanNr(3),
      value: ticketsToBuy * pricePerTicket,
    });

    console.log(
      "OWNEDTICKETS",
      await contractInstance.getOwnedTickets({
        from: fan,
      })
    );

    // TODO:
  });
});
