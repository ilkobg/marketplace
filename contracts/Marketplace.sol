// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./NFT.sol";

contract Marketplace is ReentrancyGuard {
    // nftContractAddress => tokenId => price
    mapping(address => mapping(uint256 => uint256)) public listings;

    event List(address indexed owner, uint256 indexed tokenId, address nftContractAddress, uint256 price);
    event Buy(address indexed buyer, address indexed owner, uint256 indexed tokenId, address nftContractAddress, uint256 price);
    event Cancel(address indexed owner, uint256 indexed tokenId, address indexed nftContractAddress);

    function listNFT(uint256 tokenId, uint256 price, address _nftContractAddress) external {
        require(listings[_nftContractAddress][tokenId] == 0, "Token already listed");
        require(msg.sender == IERC721(_nftContractAddress).ownerOf(tokenId), "Only owner can list the NFT for sale");
        require(price > 0, "Price must be greater than zero");

        listings[_nftContractAddress][tokenId] = price;
        
        emit List(msg.sender, tokenId, _nftContractAddress, price);
    }

    function buyNFT(uint256 tokenId, address nftContractAddress) external payable {
        require (listings[nftContractAddress][tokenId] != 0, "Token is not listed");
        require(msg.value >= listings[nftContractAddress][tokenId], "Insufficient funds");

        address seller = IERC721(nftContractAddress).ownerOf(tokenId);
        uint256 price = listings[nftContractAddress][tokenId];

        delete listings[nftContractAddress][tokenId];

        //Pay owner of the NFT
        address payable sellerAddress = payable(seller);
        (bool success, ) = sellerAddress.call{value: msg.value}("");
        if(!success) {
            revert("Transaction failed");
        }

        //Tranfer NFT to the new owner
        IERC721(nftContractAddress).transferFrom(
            seller,
            msg.sender,
            tokenId
        );

        emit Buy(msg.sender, seller, tokenId, nftContractAddress, price);
    }

    function cancelListing(uint256 tokenId, address nftContractAddress) external {
        require (listings[nftContractAddress][tokenId] != 0, "Token is not listed");
        require(msg.sender == IERC721(nftContractAddress).ownerOf(tokenId), "Only owner can cancel the listing");

        delete listings[nftContractAddress][tokenId];

        emit Cancel(msg.sender, tokenId, nftContractAddress);
    }
}