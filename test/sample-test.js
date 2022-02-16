const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Greeter", function () {
  it("Should return the new greeting once it's changed", async function () {
    const CruiseNFT = await ethers.getContractFactory("CruiseNFT");
    const cruiseNFT = await CruiseNFT.deploy("Hello, world!");
    await cruiseNFT.deployed();

    expect(await cruiseNFT.greet()).to.equal("Hello, world!");

    const setGreetingTx = await cruiseNFT.setGreeting("Hola, mundo!");

    // wait until the transaction is mined
    await setGreetingTx.wait();

    expect(await cruiseNFT.greet()).to.equal("Hola, mundo!");
  });
});
