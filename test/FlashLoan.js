const { expect } = require("chai");
const { ethers } = require("hardhat");

const tokens = (n) => {
  return ethers.utils.parseUnits(n.toString(), "ether");
};

describe("Flashloan", () => {
  let token, flashLoan, flashLoanReceiver;
  let deployer, user1;

  beforeEach(async () => {
    accounts = await ethers.getSigners();
    deployer = accounts[0];

    const FlashLoan = await ethers.getContractFactory("FlashLoan");
    const FlashLoanReceiver = await ethers.getContractFactory(
      "FlashLoanReceiver"
    );
    const Token = await ethers.getContractFactory("Token");

    token = await Token.deploy("Dapp University", "DAPP", "1000000");

    flashLoan = await FlashLoan.deploy(token.address);

    let transaction = await token
      .connect(deployer)
      .approve(flashLoan.address, tokens(1000000));
    await transaction.wait();

    transaction = await flashLoan
      .connect(deployer)
      .depositTokens(tokens(1000000));
    await transaction.wait();

    flashLoanReceiver = await FlashLoanReceiver.deploy(flashLoan.address);
  });

  describe("Deployment", () => {
    it("sends tokens to the Crowdsale contract", async () => {
      expect(await token.balanceOf(flashLoan.address)).to.equal(
        tokens(1000000)
      );
    });
  });

  describe("Borrowing funds", () => {
    it("borrows funds from the pool", async () => {
      let amount = tokens(100);
      let transaction = await flashLoanReceiver
        .connect(deployer)
        .executeFlashLoan(amount);
      let result = await transaction.wait();

      await expect(transaction)
        .to.emit(flashLoanReceiver, "LoanReceived")
        .withArgs(token.address, amount);
    });
  });
});
