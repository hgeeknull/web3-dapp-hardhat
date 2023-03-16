// This is an example test file. Hardhat will run every *.js file in `test/`
// so feel free to add new ones.

// Hardhat tests are normally writtern with Mocha and Chai.
// We import Chain to use its asserting functions here.
import { expect } from "chai";

// We use `loadFixture` to share common setups (or fixtures) between tests.
// Using this simplifies your tests and makes them run faster, by taking
// advantage of Hardhat Network's snapshot functionality.
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers"

import { ethers } from "hardhat";

// `describe` receives the name of a section of your test suite, and a
// calllback. The callback must define the tests of that section. This callback
// can't be an async function.
describe("Token contract", function(){
    // We define a fxiture to reuse the same setup in every test. We use
    // loadFixture to run this setup once, snapshot that state, and reset Hardhat
    // Network to that snapshot in every test.
    async function deployTokenFixture() {
        // Get the ContractFactory and Signers here.
        const Token = await ethers.getContractFactory("Token");
        const [owner, addr1, addr2] = await ethers.getSigners();

        // To deploy our contract, we just have to call Token.deploy() and await
        // its deployed() method, which happens once its transaction has been
        // mined.
        const hardhatToken = await Token.deploy();
        
        await hardhatToken.deployed();

        // Fixtures can return anything you consider useful for your tests
        return { Token, hardhatToken, owner, addr1, addr2 };
    }

    // You can nest describe calls to create subsections.
    describe("Deployment", function(){
        // `it` is another Mocha function. This is the one you use to define each
        // of your tests. It receives the test name, and a callback function.
        //
        // If the callback function is async, Mocha will `await` it.
        it("Should set the right owner", async function(){
            // We use loadFixture to setup our environment, and then assert that
            // things went well.
            const { hardhatToken, owner } = await loadFixture(deployTokenFixture);

            // `expect` receives a value and wraps it in an assertion object. These
            // objects have a lot of utility methods to assert values.

            // This test expects the owner variable stored in the contract to be
            // equal to our Signer's owner.
            expect(await hardhatToken.owner()).to.equal(owner.address);
        })

        it("should assign the total supply of tokens to the owner", async function(){
            const { hardhatToken, owner } = await loadFixture(deployTokenFixture);
    
            const ownerBalance = await hardhatToken.balanceOf(owner.address);
            expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
        })
    })

    describe("Transactions", function(){
        it("Should transfer tokens between accounts", async function(){
            const { hardhatToken, owner, addr1, addr2 } = await loadFixture(deployTokenFixture);
    
            // Transfer 50 tokens from owner to addr1
            await hardhatToken.transfer(addr1.address, 50);
            expect(await hardhatToken.balanceOf(addr1.address)).to.equal(50);
    
            // Transfer 50 tokens from addr1 to addr2
            await hardhatToken.connect(addr1).transfer(addr2.address, 50);
            expect(await hardhatToken.balanceOf(addr2.address)).to.equal(50);
        })
    })

    it("Should emit Transfer events", async function(){
        const { hardhatToken, owner, addr1, addr2 } = await loadFixture(deployTokenFixture);
        
        await expect(hardhatToken.transfer(addr1.address, 50))
          .to.emit(hardhatToken, "Transfer")
          .withArgs(owner.address, addr1.address, 50);

        await expect(hardhatToken.connect(addr1).transfer(addr2.address, 50))
          .to.emit(hardhatToken, "Transfer")
          .withArgs(addr1.address, addr2.address, 50);
    })

    it("Should fail if sender doesn't have enough tokens", async function(){
        const { hardhatToken, owner, addr1 } = await loadFixture(deployTokenFixture);

        const initialOwnerBalance = await hardhatToken.balanceOf(owner.address);

        // Try to send 1 token from addr1 (0 tokens) to owner.
        // `require` will evaluate false and revert the transaction.
        await expect(
            hardhatToken.connect(addr1).transfer(owner.address, 1)
        ).to.be.revertedWith("Not enough tokens");

        // Owner balance shouldn't have changed.
        await expect(await hardhatToken.balanceOf(owner.address)).to.equal(
            initialOwnerBalance
        );
    })
})