const { expect, should } = require('chai');

const NAME = "GyuliArt"
const SYMBOL = "GA"
const BASE_URI = "https://www.youtube.com/"
const ZERO_ADDRESS = "0x00000000000000000000000000000000"

describe("Art", function () {
    let artContract;
	let owner;
	let tokenOwner;
	let tokenApproved;

	beforeEach(async () => {
		[owner, tokenOwner, tokenApproved] = await hre.ethers.getSigners();
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
	
	describe("Token interaction", async () => {

		const tokenId = 0;
		beforeEach(async() => {
			const mintTx = await artContract.safeMint(tokenOwner.address, tokenId);
			await mintTx.wait();
		})

		it("Owner should be correct", async () => {
			const tokenOwner = await artContract.ownerOf(tokenId);
			expect(tokenOwner).to.be.equal(tokenOwner.address);
		})

		it("Owner should have balance", async () => {
			const balance = 1;

			const addressBalance = await artContract.balanceOf(tokenOwner.address);
			expect(addressBalance).to.be.equal(balance);
		})

	})

	// describe("Burn", () => {
	// 	let tokenId = 0;
	// 	beforeEach(async() => {
	// 		const burn = await artContract.burn(tokenId);
	// 		await burn.wait();
	// 	})

	// 	it("Owner should be correct", async () => {
	// 		const tokenOwner = await artContract.ownerOf(tokenId);
	// 		expect(tokenOwner).to.be.equal(tokenOwner.address);
	// 	})

	// 	it("Owner should have balance", async () => {
	// 		let balance = 1;
	// 		const addressBalance = await artContract.balanceOf(tokenOwner.address);
	// 		expect(addressBalance).to.be.equal(balance);
	// 	})
		
	// 	it("", async () => {
	// 		const 
	// 	})
	// })

	describe("Approval", async() => {
		let tokenId = 0;
		beforeEach(async() => {
			const mintTx = await artContract.safeMint(owner.address, tokenId);
			await mintTx.wait();
		})

		it("getApproved for token without approved should return zero ", async () => {
			const getApproved = await artContract.connect(owner).getApproved(tokenId);
			console.log(getApproved);
			expect(parseInt( getApproved, 16)).to.be.equal(0);
		})

		it("getApproved for token with approved should return approved address", async () => {
			const txApprove = await artContract.connect(owner).approve(tokenOwner.address, tokenId);
			await txApprove.wait();
			const getApproved = await artContract.connect(owner).getApproved(tokenId);
			console.log(getApproved);

			expect(getApproved).to.be.equal(tokenOwner.address);
		})

		it("Approval from non-owner-tokens should fail", async () => {
			const txApprove = await artContract.connect(tokenOwner).approve(tokenApproved.address, tokenId);
			await txApprove.wait();
			expect(txApprove).to.be.revertedWith("ERC721: approve caller is not token owner nor approved for all");
		})

		it("Self approval should fail", async () =>  {
			const txApprove = await artContract.connect(owner).approve(owner.address, tokenId);
			await txApprove.wait();
			expect(txApprove).to.be.revertedWith("ERC721: approval to current owner");

		})

	})

	describe("TransferFrom", async () => {
		let tokenId = 0;

		beforeEach(async () => {
			const txMint = await artContract.safeMint(owner.address, tokenId);
			await txMint.wait();
		})

		it("Transfer to 0 address should fail",  async () => {
			const txTransferFrom = artContract.connect(tokenOwner)
									["transferFrom(address,address,uint256)"]
									(tokenOwner, contracts.ZERO_ADDRESS, tokenId);

			expect(txTransferFrom).to.be.revertedWith("ERC721: transfer from incorrect owner");
		})

		it("Transfer from non token owner should fail",  async () => {
			const txTransferFrom = 
			artContract.connect(owner)["transferFrom(address,address,uint256)"]
			(tokenOwner, contracts.ZERO_ADDRESS, tokenId);

			expect(txTransferFrom).to.be.revertedWith("ERC721: transfer from incorrect owner");
		})


		it("Transfer from token owner should successed", async () => {
			const txTransferFrom = await artContract.connect(tokenOwner).transferFrom(tokenOwner.address, tokenApproved.address, tokenId);
			await txTransferFrom.wait();
			const newOwner = await artContract.ownerOf(tokenId);
			expect(newOwner).to.be.equal(tokenApproved.address);
		})

		it("Transfer for approved address should work", async () => {
			const txApprove = await artContract.connect(owner).approve(tokenOwner.address, tokenId);
			await txApprove.wait();
			await artContract.connect(tokenOwner)
							["transferFrom(address,address,uint256)"](
															owner.address,
															tokenApproved.address,
															tokenId);
			const newOwner = await artContract.ownerOf(tokenId);
			console.log(newOwner, tokenApproved.address);

			expect(newOwner).to.be.equal(tokenApproved.address);

		});
		
	});

});