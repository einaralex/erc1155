module.exports = {
  compilers: {
    solc: {
      version: "^0.8.0",
    },
  },
  //  <http://truffleframework.com/docs/advanced/configuration>
  networks: {
    develop: {
      accounts: 15,
      defaultEtherBalance: 300,
    },
    development: {
      host: "127.0.0.1",
      port: 9545,
      network_id: "*",
    },
    // test: {
    //   host: "127.0.0.1",
    //   port: 7545,
    //   network_id: "*",
    // },
  },
  //},
  //
  // Truffle DB is currently disabled by default; to enable it, change enabled:
  // false to enabled: true. The default storage location can also be
  // overridden by specifying the adapter settings, as shown in the commented code below.
  //
  // NOTE: It is not possible to migrate your contracts to truffle DB and you should
  // make a backup of your artifacts to a safe location before enabling this feature.
  //
  // After you backed up your artifacts you can utilize db by running migrate as follows:
  // $ truffle migrate --reset --compile-all
  //
  // db: {
  // enabled: false,
  // host: "127.0.0.1",
  // adapter: {
  //   name: "sqlite",
  //   settings: {
  //     directory: ".db"
  //   }
  // }
  // }
};
