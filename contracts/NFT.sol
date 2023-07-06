//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("Trade NFTs", "NFT") {}

    function safeMint(address marketplaceAddress, address creator) public payable returns (uint) {
        uint256 tokenId = _tokenIdCounter.current();

        _mint(creator, tokenId);
        approve(marketplaceAddress, tokenId);
        _tokenIdCounter.increment();

        return tokenId;
    }
}