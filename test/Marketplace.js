const { expect } = require("chai");

describe("Marketplace", function () {
  let marketplace;
  let nftContract;
  let owner;
  let buyer;
  const tokenId = 0;
  const price = ethers.utils.parseEther("1");
  let nftContractAddress;

  beforeEach(async function () {
    [owner, buyer] = await ethers.getSigners();

    // Deploy the NFT contract
    const NFTContract = await ethers.getContractFactory("NFT");
    nftContract = await NFTContract.deploy();

    // Deploy the Marketplace contract
    const Marketplace = await ethers.getContractFactory("Marketplace");
    marketplace = await Marketplace.deploy();

    await nftContract.deployed();
    await marketplace.deployed();

    nftContractAddress = nftContract.address;

    // Mint an NFT
    await nftContract.safeMint(marketplace.address, owner.address);
  });

  it("Should list an NFT for sale", async function () {
    await marketplace.connect(owner).listNFT(tokenId, price, nftContractAddress);

    const listing = await marketplace.listings(tokenId);
    expect(listing.owner).to.equal(owner.address);
    expect(listing.price).to.equal(price);

    expect(await nftContract.ownerOf(tokenId)).to.equal(owner.address);

    const filter = marketplace.filters.List();
    const events = await marketplace.queryFilter(filter);

    expect(events.length).to.equal(1);
  });

  it("Should throw when listing an NFT that is already listed", async function () {
    await marketplace.connect(owner).listNFT(tokenId, price, nftContractAddress);

    const listing = await marketplace.listings(tokenId);
    expect(listing.owner).to.equal(owner.address);
    expect(listing.price).to.equal(price);

    expect(await nftContract.ownerOf(tokenId)).to.equal(owner.address);

    expect(marketplace.connect(owner).listNFT(tokenId, price, nftContractAddress))
      .to.be.revertedWith("NFT is already listed");
  });

  it("Should throw when listing an NFT with zero price", async function () {

    expect(marketplace.connect(owner).listNFT(tokenId, 0, nftContractAddress))
      .to.be.revertedWith("Price must be greater than zero");
  });


  it("Should buy an NFT", async function () {
    await marketplace.connect(owner).listNFT(tokenId, price, nftContractAddress);

    const initialBalanceSeller = await ethers.provider.getBalance(owner.address);
    const initialBalanceBuyer = await ethers.provider.getBalance(buyer.address);

    const transaction = await marketplace.connect(buyer).buyNFT(tokenId, { value: price });
    const receipt = await transaction.wait();

    const gasUsed = receipt.gasUsed;
    const gasPrice = transaction.gasPrice;
    const gasFee = gasUsed.mul(gasPrice);

    const updatedBalanceSeller = await ethers.provider.getBalance(owner.address);
    const updatedBalanceBuyer = await ethers.provider.getBalance(buyer.address);

    expect(updatedBalanceSeller).to.equal(initialBalanceSeller.add(price));
    expect(updatedBalanceBuyer).to.equal(initialBalanceBuyer.sub(price).sub(gasFee));

    expect(await nftContract.ownerOf(tokenId)).to.equal(buyer.address);

    const filter = marketplace.filters.Buy();
    const events = await marketplace.queryFilter(filter);

    expect(events.length).to.equal(1);
  });

  it("Should throw when trying to buy NFT that is not listed", async function () {

    expect(marketplace.connect(buyer).buyNFT(tokenId, { value: price }))
      .to.be.revertedWith("Token is not listed");
  });

  it("Should throw when trying to buy NFT with unsufficient funds", async function () {
    await marketplace.connect(owner).listNFT(tokenId, price, nftContractAddress);

    const smallerPrice = price - 100;

    expect(marketplace.connect(buyer).buyNFT(tokenId, { value: smallerPrice }))
      .to.be.revertedWith("Insufficient funds to buy the NFT");
  });

  it("Should cancel a listing", async function () {
    await marketplace.connect(owner).listNFT(tokenId, price, nftContractAddress);

    await marketplace.connect(owner).cancelListing(tokenId);

    expect(await nftContract.ownerOf(tokenId)).to.equal(owner.address);

    const filter = marketplace.filters.Cancel();
    const events = await marketplace.queryFilter(filter);

    expect(events.length).to.equal(1);
  });

  it("Should throw when trying to cancel NFT listing that is not listed", async function () {

    expect(marketplace.connect(owner).cancelListing(tokenId))
      .to.be.revertedWith("Token is not listed");
  });

  it("Should throw when trying to cancel NFT listing with not the owner", async function () {

    expect(marketplace.connect(buyer).cancelListing(tokenId))
      .to.be.revertedWith("Caller is not the owner");
  });
});
