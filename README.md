# NFT Marketplace Smart Contract

## Overview
Final project for Lime Academy Season 6: NFT Marketplace with BE.
This repo contains a Hardhat project with SC for the Marketplace and a simple ERC721 NFT contract for easier testing. Also, it contains tests for the Marketplace and deployment scripts.

## Requirements
- solidity v0.8.17
- hardhat v2.14.0
- dotenv

## Testing
The two contracts are deployed to Goerli network and verified via Etherscan on the following addresses:

[Marketplace.sol](https://goerli.etherscan.io/address/0x87Bde8263c60AB5a451510d465a22a1E76Df8C01)
[NFT.sol](https://goerli.etherscan.io/address/0xe0852fF3Ade879B865a0685e0F1cF1BEec8bce34#code)

Also, contracts can be deployed on local network, running a local Hardhat node.

### Deployment

1. **On local network**
- Run local node with `npx hardhat node`
- In another terminal, run `npx hardhat deploy-pk --private-key PRIVATE_KEY --network localhost`, where PRIVATE_KEY is one of the PKs provided from the Hardhat node.
- Also `npx hardhat deploy` can be used, which will deploy the contracts on the localhost with the first two accounts.

2. **On Goerli network**
- Setup environment variables in .env file: Infura API key; private key of the deployer account (can be provided from terminal) and Etherscan API key for verification.
- Deploy with `npx hardhat deploy-pk --private-key PRIVATE_KEY --network goerli`
- Etherscan verification can be done with `npx hardhat verify --network goerli "CONTRACT_ADDRESS"`

## NFT.sol

The smart contract inherits from Openzeppelin's ERC721URIStorage. It uses Counters.sol for keeping track of the IDs of the minted tokens.

It provides function `safeMint(address marketplaceAddress, address creator)`, which accepts address of the Marketplace contract and address of the creator(owner) of the token.

Approval for the minted token is done in the safeMint function and the Marketplace is the approved one to be able to work with the token.

## Marketplace.sol

Marketplace contract is very simple. It inherits ReentrancyGuard Openzeppelin's contract.
We have several points of interest for every listing:
- owner
- tokenId
- nftContractAddress
- price

Listings are kept in nested mapping, which is mapping with nftContractAddress as key to mapping with tokenId as key and price as value. The reason for this is that we can have tokens from different NFT contracts (different collections) and for every collection we keep mapping with token IDs and price.

The owner is get from the interface of ERC721 contract with the helper function `ownerof()`.

The nested mapping is updated dynamically, meaning that on cancelling a listing or on selling, the listing is deleted.

The contract emits three events: List, Buy and Cancel, which correspond to the three functions: listNFT, buyNFT and cancelListing.

To keep the Marketplace as simple as possible, the logic for getting information about active listings, collection statistics and etc., is done in the API part, which reads this information from the Indexer.
