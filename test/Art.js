const { expect, should } = require('chai');

const NAME = "GyuliArt"
const SYMBOL = "GA"
const BASE_URI = "https://www.youtube.com/"
const ZERO_ADDRESS = "0x00000000000000000000000000000000"

describe("Art", function () {
    let artContract;
	let owner;
	let user2;
	let user3;

	beforeEach(async () => {
		[owner, user2, user3] = await hre.ethers.getSigners();
		const Art = await hre.ethers.getContractFactory("Art")
		const art = await Art.deploy(
			NAME,
			SYMBOL,
			BASE_URI
		);

		await art.deployed();
		artContract = art;
	})

	describe("Deploy", async () => {

		it("Be delpoyed", () => {
			const address = artContract.address;
			expect(address).to.exist;
		})
		
		it("Have correct baseURL", async () => {
			const baseURL = await artContract.__baseURI();
			expect(baseURL).to.be.equal(BASE_URI);
		})

		it("Have correct name", async () => {
			const name = await artContract.name();
			expect(name).to.be.equal(NAME);
		})

		it("Have correct symbol", async () => {
			const symbol = await artContract.symbol();
			expect(symbol).to.be.equal(SYMBOL);
		})

		it("Have correct owner", async () => {
			const ownerAddress = await artContract.owner();
			expect(ownerAddress).to.be.equal(owner.address);
		})

	})
	
	describe("Mint", async () => {
		const balance = 1;
		const tokenId = 0;
		beforeEach(async() => {
			await artContract.safeMint(user2.address, tokenId);
		})

		it("Owner should be correct", async () => {
			const user2 = await artContract.ownerOf(tokenId);
			expect(user2).to.be.equal(user2);
		})

		it("Owner should have balance", async () => {
			const addressBalance = await artContract.balanceOf(user2.address);
			expect(addressBalance).to.be.equal(balance);
		})

		it("Should fail if caller is not contract owner", async () => {
			let mint = await artContract.connect(user3).safeMint(user2.address, 1)
			expect(mint).to.be.revertedWith("Ownable: caller is not the owner");
		})

		it("Should fail if minted to zero address", async () => {
			expect( artContract.safeMint(ZERO_ADDRESS, tokenId)).to.be.revertedWith("ERC721: mint to the zero address");
		})

	})

	describe("Burn", () => {
		let tokenId = 0;
		beforeEach(async() => {
			const mintTx = await artContract.safeMint(user2.address, tokenId);
			await mintTx.wait();
		})
		
		it("Balance should be 0 ", async () => {
			await artContract.connect(user2)["burn(uint256)"](tokenId);
			const balance = await artContract.balanceOf(user2.address);
			expect(balance).to.be.equal(0);
		})

		it("Should fail if token invalid", async () => {
			expect(artContract.connect(user2)["burn(uint256)"](3)).to.be.revertedWith("ERC721: invalid token ID");
		})
                         
		it("Should fail if caller is not token owner", async () => {
			expect(await artContract.connect(user3)["burn(uint256)"](tokenId)).to.be.revertedWith("ERC721: invalid token ID");
		})
	})

	describe("Approval", async() => {
		let tokenId = 0;
		beforeEach(async() => {
			await artContract.safeMint(user2.address, tokenId);
		})

		it("getApproved for token without approved should return zero ", async () => {
			const getApproved = await artContract.connect(user2).getApproved(tokenId);
			expect(parseInt( getApproved, 16)).to.be.equal(0);
		})

		it("getApproved for token with approved should return approved address", async () => {
			await artContract.connect(user2).approve(user3.address, tokenId);
			const getApproved = await artContract.connect(owner).getApproved(tokenId);
			expect(getApproved).to.be.equal(user3.address);
		})

		it("Approval from non-owner-tokens should fail", async () => {
			await expect( artContract.connect(user3).approve(owner.address, tokenId)).to.be.revertedWith("ERC721: approve caller is not token owner nor approved for all");
		})

		it("Self approval should fail", async () =>  {
			await expect(artContract.connect(user2)["approve(address,uint256)"](user2.address, tokenId)).
			to.be.revertedWith("ERC721: approval to current owner");
		})
	})

	describe("TransferFrom", async () => {
		let tokenId = 0;

		beforeEach(async () => {
			await artContract.safeMint(user2.address, tokenId);
		})

		it("Transfer to 0 address should fail",  async () => {
			expect(artContract.connect(user2)
			["transferFrom(address,address,uint256)"]
			(user2,ZERO_ADDRESS, tokenId)).to.be.revertedWith("ERC721: transfer from incorrect owner");
		})

		it("Transfer from non token owner should fail",  async () => {
			expect(artContract.connect(owner)["transferFrom(address,address,uint256)"]
			(user2, user3, tokenId)).to.be.revertedWith("ERC721: transfer from incorrect owner");
		})

		it("Transfer from token owner should successed", async () => {
			await artContract.connect(user2).transferFrom(user2.address, user3.address, tokenId);
			const newOwner = await artContract.ownerOf(tokenId);
			expect(newOwner).to.be.equal(user3.address);
		})

		it("Transfer for approved address should work", async () => {
			await artContract.connect(user2).approve(owner.address, tokenId);
			await artContract.connect(owner)
							["transferFrom(address,address,uint256)"](
															user2.address,
															user3.address,
															tokenId);
			const newOwner = await artContract.ownerOf(tokenId);
			expect(newOwner).to.be.equal(user3.address);

		});
		
	});

	describe("setApprovalForAll", async () => {
		let tokenId = 0;
		beforeEach(async() => {
			await artContract.safeMint(user2.address, tokenId);
		})

		it("Approval from owner-tokens should success", async () => {
			let bool = 1;
			await artContract.connect(user2).setApprovalForAll(user3.address, bool);
			const owner = await artContract.connect(user2).ownerOf(tokenId);
			expect(owner).to.be.equal(user2.address);
		})

		it("Approval from non-owner-tokens should fail", async () => {
			let bool = 1;
			 expect(await artContract.connect(user3).setApprovalForAll(owner.address, bool)).to.be.
					revertedWith("approve caller is not token owner nor approved for all");
		})

		it("Should success if approved for all", async () => {
			let bool = 1;

			await artContract.connect(user2).setApprovalForAll(user3.address, bool);
			let isApprovedForAll = await artContract.connect(user3).isApprovedForAll(user2.address, user3.address);
			expect(isApprovedForAll).to.be.equal(true);
		})

		
		it("Should success if approved for all", async () => {
			let bool = 1;
			await artContract.connect(user2).setApprovalForAll(user3.address, bool);
			await artContract.connect(user2).transferFrom(user2.address, user3.address, tokenId);
			const towner = await artContract.connect(user2).ownerOf(tokenId);
			expect(towner).to.be.equal(user3.address);
		})

	})

});