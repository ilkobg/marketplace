// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./NFT.sol";

contract Marketplace is ReentrancyGuard {
    struct Listing {
        address owner;
        address nftContractAddress;
        uint256 tokenId;
        uint256 price;
    }

    mapping(uint256 => Listing) public listings;

    event List(address indexed owner, uint256 indexed tokenId, address nftContractAddress, uint256 price);
    event Buy(address indexed buyer, address indexed owner, uint256 indexed tokenId, address nftContractAddress, uint256 price);
    event Cancel(address indexed owner, uint256 indexed tokenId, address indexed nftContractAddress);

    function listNFT(uint256 tokenId, uint256 price, address _nftContractAddress) external {
        require (listings[tokenId].owner == address(0), "Token already listed");
        require(price > 0, "Price must be greater than zero");

        listings[tokenId] = Listing({
            owner: msg.sender,
            tokenId: tokenId,
            price: price,
            nftContractAddress: _nftContractAddress
        });

        emit List(msg.sender, tokenId, _nftContractAddress, price);
    }

    // seller -> listings[tokenId].owner
    // buyer -> msg.sender
    function buyNFT(uint256 tokenId) external payable {
        require (listings[tokenId].owner != address(0), "Token is not listed");
        require(msg.value >= listings[tokenId].price, "Insufficient funds");

        address seller = listings[tokenId].owner;
        uint256 price = listings[tokenId].price;
        address _nftContractAddress = listings[tokenId].nftContractAddress;

        //Pay owner of the NFT
        address payable sellerAddress = payable(seller);
        sellerAddress.transfer(msg.value);

        //Tranfer NFT to the new owner
        IERC721(_nftContractAddress).transferFrom(
            listings[tokenId].owner,
            msg.sender,
            listings[tokenId].tokenId
        );

        delete listings[tokenId];

        emit Buy(msg.sender, seller, tokenId, _nftContractAddress, price);
    }

    function cancelListing(uint256 tokenId) external {
        require (listings[tokenId].owner != address(0), "Token is not listed");
        require(msg.sender == listings[tokenId].owner, "Only owner can cancel the listing");

        address _nftContractAddress = listings[tokenId].nftContractAddress;

        delete listings[tokenId];

        emit Cancel(msg.sender, tokenId, _nftContractAddress);
    }
}