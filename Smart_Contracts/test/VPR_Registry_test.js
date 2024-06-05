const MyContract = artifacts.require("VPR_Registry_Contract");

contract("MyContract", accounts => {
  let myContract;

  before(async () => {
    // Deploy a new instance of MyContract before running tests
    myContract = await MyContract.new();
  });

  describe("initial state", () => {
    it("should initially set the stored number to 0", async () => {
      const storedNumber = await myContract.getMyNumber();
      assert.equal(storedNumber.toNumber(), 0, "The initial number is not 0");
    });
  });

  describe("setMyNumber", () => {
    it("should set the stored number to a new value", async () => {
      await myContract.setMyNumber(42);
      const storedNumber = await myContract.getMyNumber();
      assert.equal(storedNumber.toNumber(), 42, "The number 42 was not stored");
    });
  });

  describe("interaction between accounts", () => {
    it("should allow an account to update the number and reflect changes", async () => {
      await myContract.setMyNumber(100, { from: accounts[1] });
      const storedNumber = await myContract.getMyNumber();
      assert.equal(storedNumber.toNumber(), 100, "The number 100 was not stored by account 1");
    });
  });
});
