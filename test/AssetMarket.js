const { expect, should } = require('chai');

const NAME = "GyuliArt";
const SYMBOL = "GA";
const BASE_URI = "https://www.youtube.com/";

describe("AssetMarket", function () {
    let assetMarketContract;
	let assetArt;
    let owner;
    let user2;
	let user3;

    beforeEach(async () => {
		[owner, user2, user3] = await hre.ethers.getSigners();
		const Market = await hre.ethers.getContractFactory("AssetMarket");
		const Art = await hre.ethers.getContractFactory("Art");

		const market = await Market.deploy();

		const art = await Art.deploy(
			NAME,
			SYMBOL,
			BASE_URI
		);
		await market.deployed();
		await art.deployed();

		assetMarketContract = market;
		assetArt = art;
	})

    describe("Deploy", async () => {

		it("Be delpoyed", () => {
			const address = assetMarketContract.address;
			expect(address).to.exist;
		})
		
		it("Have correct owner", async () => {
			const contractOwner = await assetMarketContract.owner();
			expect(contractOwner).to.be.equal(owner.address);
		  })

	})

	describe("Sale", () => {
		let tokenId = "0";
		let price = "1000000000000000000";
		let saleId = 0;
		beforeEach(async() => {
			await assetArt.safeMint(user2.address, tokenId);
		})

		it("Should fail if caller is not token owner", async () => {
			await expect(assetMarketContract.connect(user3)["sale(address,uint256,uint256)"]
					(assetArt.address, tokenId, price)).
					to.be.revertedWith("You are not an asset owner");
		})

		it("Should fail if address is not approved", async () => {
			await expect(assetMarketContract.connect(user3)["sale(address,uint256,uint256)"]
					(assetArt.address, tokenId, price)).
					to.be.revertedWith("You are not an asset owner");
		})

		it("Should fail if sale is note created", async () => {
			await assetArt.connect(user2).approve(assetMarketContract.address, tokenId);
			await assetMarketContract.connect(user2)["sale(address,uint256,uint256)"]
					(assetArt.address, tokenId, price);

			const userSales = await assetMarketContract.saleByAddress(user2.address);

			expect(userSales).to.not.be.empty;

			const saleTokenId = userSales[0][0].toString();
			expect(saleTokenId).to.be.equal(tokenId);

			const salePrice = userSales[0][1].toString();
			expect(salePrice).to.be.equal(price);

			const contractAddress = userSales[0][2].toString();
			expect(contractAddress).to.be.equal(assetArt.address);

			const tokenOwner = userSales[0][3].toString();
			expect(tokenOwner).to.be.equal(user2.address);
		})

		it("Should fail if sale id does not exist ", async () => {
			await assetArt.connect(user2).approve(assetMarketContract.address, tokenId);
			await assetMarketContract.connect(user2)["sale(address,uint256,uint256)"]
					(assetArt.address, tokenId, price);
			const userSales = await assetMarketContract.saleById(saleId);
			expect(userSales).to.not.be.empty;
		})

		it("Should fail if sale address does not exist ", async () => {
			await assetArt.connect(user2).approve(assetMarketContract.address, tokenId);
			await assetMarketContract.connect(user2)["sale(address,uint256,uint256)"]
					(assetArt.address, tokenId, price);
			const userSales = await assetMarketContract.saleByAddress(user2.address);
			expect(userSales).to.not.be.empty;
		})
	})

	

	describe("Auction", () => {

		let tokenId = "0";
		let auctionDuration = "1111";
		let minBid = "1000000000000000000";

		beforeEach(async() => {
			await assetArt.safeMint(user2.address, tokenId);
		}) 

		it("Should fail if caller is not token owner", async () => {
			await expect(assetMarketContract.connect(user3)["auction(address,uint256,uint256,uint256)"]
					(assetArt.address, tokenId, minBid, auctionDuration)).
					to.be.revertedWith("You are not an asset owner");
		})

		it("Should fail if address is not approved", async () => {
			await expect(assetMarketContract.connect(user2)["auction(address,uint256,uint256,uint256)"]
					(assetArt.address, tokenId, minBid, auctionDuration)).
					to.be.revertedWith("Market is not approved for the token");
		})

		it("Should fail if minbid is 0", async () => {
			await assetArt.connect(user2).approve(assetMarketContract.address, tokenId);

			await expect(assetMarketContract.connect(user2)["auction(address,uint256,uint256,uint256)"]
					(assetArt.address, tokenId, 0, auctionDuration)).
					to.be.revertedWith("Price should be more then 0");
		})

		it("Should fail if auction is not created", async () => {
			await assetArt.connect(user2).approve(assetMarketContract.address, tokenId);
			await assetMarketContract.connect(user2)["auction(address,uint256,uint256,uint256)"]
					(assetArt.address, tokenId, minBid, auctionDuration);

			const auctions = await assetMarketContract.connect(user2).auctionByAddress(user2.address);

			expect(auctions).to.not.be.empty;

			const auction = auctions[0][0].toString();
			expect(auction).to.be.equal(tokenId);

			const minBidPrice = auctions[0][1].toString();
			expect(minBidPrice).to.be.equal(minBid);

			const contractAddress = auctions[0][2].toString();
			expect(contractAddress).to.be.equal(assetArt.address);

			const tokenOwner = auctions[0][3].toString();
			expect(tokenOwner).to.be.equal(user2.address);

			const duration = auctions[0][4].toString();
			expect(duration).to.be.equal(auctionDuration);
		})

		it("Should fail if auction id does not exist ", async () => {
			await assetArt.connect(user2).approve(assetMarketContract.address, tokenId);
			await assetMarketContract.connect(user2)["auction(address,uint256,uint256,uint256)"]
					(assetArt.address, tokenId, minBid, auctionDuration);
			const auctions = await assetMarketContract.auctionById(tokenId);
			expect(auctions).to.not.be.empty;
		})

		it("Should fail if auction address not exist ", async () => {
			await assetArt.connect(user2).approve(assetMarketContract.address, tokenId);
			await assetMarketContract.connect(user2)["auction(address,uint256,uint256,uint256)"]
					(assetArt.address, tokenId, minBid, auctionDuration);
			const auctions = await assetMarketContract.auctionByAddress(user2.address);
			expect(auctions).to.not.be.empty;
		})

	})

	describe("bid", async () => {
		let tokenId = "0";
		let minBid = "1000000000000000000";
		let auctionDuration = "1";
		let cost =  "1000000000000000000";
		let auctionId = 0;

		beforeEach(async() => {
			await assetArt.safeMint(user2.address, tokenId);
			await assetArt.connect(user2).approve(assetMarketContract.address, tokenId);
			await assetMarketContract.connect(user2)["auction(address,uint256,uint256,uint256)"]
					(assetArt.address, tokenId, minBid,auctionDuration);
		})

		it("Should fail if auction does not exist", async() => {
			const auction = await assetMarketContract.connect(user3).auctionById(tokenId);
			expect(auction).to.not.be.empty;
		})

		it("Should be success if caller is highest bid owner", async () => {
			await assetMarketContract.connect(user3).bid(auctionId, {value: cost});
			const highestBid = await assetMarketContract.connect(user3).highestBid(auctionId);
			expect(highestBid).to.be.equal(cost);

		})

		it("Should success if user bid is 0", async () => {
			await assetMarketContract.connect(user3).bid(auctionId, {value: cost});
			let bid = await assetMarketContract.connect(user2).currentBid(auctionId);
			expect(bid).to.be.equal(0);
		})

		it("Should fail if auction already ended", async() => {
			let auction = 1;
			await assetArt.safeMint(user2.address, 1);
			await assetArt.connect(user2).approve(assetMarketContract.address, 1);
			await assetMarketContract.connect(user2)
					["auction(address,uint256,uint256,uint256)"]
					(assetArt.address, 1, minBid, 0);
					await expect(assetMarketContract["bid(uint256)"](auction, {value: cost}))
			 		.to.be.rejectedWith("Auction already ended");
		})

		it("Should fail if called by token owner", async() => {
			await assetArt.safeMint(user2.address, 1);
			await assetArt.connect(user2).approve(assetMarketContract.address, 1);
			await assetMarketContract.connect(user2)
			await expect(assetMarketContract.connect(user2)["bid(uint256)"](auctionId, {value: cost})).
			to.be.revertedWith("Owner cannot do bid");	
		})

		it("Should fail if bid is 0", async() => {
			await expect(assetMarketContract.connect(user3)["bid(uint256)"](auctionId, {value: 0}))
			.to.be.revertedWith("Sum cannot be 0");	
		})

	})

	describe("executeAuction", async () => {
		let tokenId = "0";
		let auctionDuration = "1111";
		let minBid = "1000000000000000000";
		let auctionId = 0;

		beforeEach(async () => {
			await assetArt.safeMint(user2.address, tokenId);
			await assetArt.connect(user2).approve(assetMarketContract.address, tokenId);
			await assetMarketContract.connect(user2)["auction(address,uint256,uint256,uint256)"]
			(assetArt.address, auctionId, minBid,auctionDuration);
		})

		it("Should fail if caller is not a auction owner", async () => {
			await expect(assetMarketContract.connect(user3)["executeAuction(uint256)"](auctionId))
				.to.be.revertedWith("You are not an auction owner");

		})

		it("Should success if caller is a auction owner", async () => {
			const auction = await assetMarketContract.auctionById(auctionId);
			expect(user2.address).to.be.equal(auction[3].toString());

		})

	})

	describe("cencelBid", async () => {
		let tokenId = "0";
		let minBid = "1000000000000000000";
		let auctionDuration = "1";
		let cost =  "1000000000000000000";
		let auctionId = 0;

		beforeEach(async() => {
			await assetArt.safeMint(user2.address, tokenId);
			await assetArt.connect(user2).approve(assetMarketContract.address, tokenId);
			await assetMarketContract.connect(user2)["auction(address,uint256,uint256,uint256)"]
					(assetArt.address, tokenId, minBid, auctionDuration);
			await assetMarketContract.connect(user3).bid(auctionId, {value: cost});

		})

		it("Should fail if caller is not a bid owner", async () => {
			let userBid = await assetMarketContract.connect(user2).currentBid(auctionId);
			 expect(userBid).to.be.equal(0);

		})

		it("Should succes if caller is bid owner", async () => {
			let userBid = await assetMarketContract.connect(user3).currentBid(auctionId);
			 expect(userBid).to.be.greaterThan(0);
		})

		it("Should succes if caller is higher bid owner", async () => {
			let userBid = await assetMarketContract.connect(user3).currentBid(auctionId);
			let higherBid = await assetMarketContract.connect(user3).highestBid(auctionId);
			expect(userBid).to.be.equal(higherBid);
		})

	})

	describe("purchase", async () => {
		let tokenId = "0";		
		let price = "1000000000000000000";

		beforeEach(async() => {
			await assetArt.safeMint(user2.address, tokenId);
			await assetArt.connect(user2).approve(assetMarketContract.address, tokenId);
			await assetMarketContract.connect(user2).sale(assetArt.address, tokenId, price);
		})

		it("Should success if value is enugh", async () => {
			let cost = "1000000000000000000";

			await assetMarketContract.connect(user3).purchase(0, {value: cost});
			let owner = await assetArt.ownerOf(tokenId);
			expect(owner).to.be.equal(user3.address);
		})

		it("Should fail if value is not enugh", async () => {
			let cost = "1000000000000000";

			await expect(assetMarketContract["purchase(uint256)"](tokenId, {value: cost})).to.be.
			revertedWith("Value is not enugh");
		})
		
	})
}) 