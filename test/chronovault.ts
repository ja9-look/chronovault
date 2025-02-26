const { expect } = require("chai");
const { describe, it } = require("mocha");
const hre = require("hardhat");
const ethers = hre.ethers;

describe("Hardhat Configuration Test", function () {
    it("should retrieve accounts from the configured network", async function () {
        const accounts = await ethers.getSigners();
        console.log(accounts);
        expect(accounts.length).to.be.greaterThan(0);
    });
    
    it("should retrieve the network details", async function () {
        const network = await ethers.provider.getNetwork();
        console.log(network.chainId);
        expect(network).to.have.property("chainId");
    });
});