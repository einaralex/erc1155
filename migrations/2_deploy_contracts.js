const HelperLib = artifacts.require("HelperLib");
const Tickets = artifacts.require("Tickets");

module.exports = function (deployer) {
  deployer.deploy(HelperLib);
  deployer.link(HelperLib, Tickets);
  deployer.deploy(Tickets);
};
