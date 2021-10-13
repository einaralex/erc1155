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
  beforeEach(async () => {
    contractInstance = await Tickets.deployed();
    mintedTokensReceipt = await contractInstance.createTicketTokens(
      ticketsAvailable,
      pricePerTicket,
      {
        from: artist,
      }
    );
    eventId = mintedTokensReceipt.receipt.logs[0].args.id.toString();
  });
  it("should mint a new set of tokens", async () => {
    assert.equal(
      await contractInstance.balanceOf(artist, eventId),
      ticketsAvailable
    );
  });
  it("should revert if msg.value is not enough for a ticket", async () => {
    await truffleAssert.reverts(
      contractInstance.buyTicketToken(artist, 1, eventId, {
        from: fan,
        value: 999,
      }),
      "Not sufficient funds"
    );
  });
  it("should allow a fan to buy ticket if msg.value is sufficient.", async () => {
    let ticketsToBuy = 2;
    await contractInstance.buyTicketToken(artist, ticketsToBuy, eventId, {
      from: fan,
      value: ticketsToBuy * pricePerTicket,
    });

    assert.equal(
      await contractInstance.balanceOf(artist, eventId),
      ticketsAvailable - ticketsToBuy
    );
    assert.equal(await contractInstance.balanceOf(fan, eventId), ticketsToBuy);
  });
});
