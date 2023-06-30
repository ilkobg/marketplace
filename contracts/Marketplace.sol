// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./NFT.sol";

contract Marketplace is ReentrancyGuard {
    struct Listing {
        address owner;
        address nftContractAddress;
        uint256 tokenId;
        uint256 price;
    }

    mapping(address => mapping(uint256 => Listing)) public listings;

    event List(address indexed owner, uint256 indexed tokenId, address nftContractAddress, uint256 price);
    event Buy(address indexed buyer, address indexed owner, uint256 indexed tokenId, address nftContractAddress, uint256 price);
    event Cancel(address indexed owner, uint256 indexed tokenId, address indexed nftContractAddress);

    function listNFT(uint256 tokenId, uint256 price, address _nftContractAddress) external {
        require(listings[_nftContractAddress][tokenId].owner == address(0), "Token already listed");
        require(msg.sender == IERC721(_nftContractAddress).ownerOf(tokenId), "Only owner can list the NFT for sale");
        require(price > 0, "Price must be greater than zero");

        listings[_nftContractAddress][tokenId] = Listing({
            owner: msg.sender,
            tokenId: tokenId,
            price: price,
            nftContractAddress: _nftContractAddress
        });
        
        emit List(msg.sender, tokenId, _nftContractAddress, price);
    }

    function buyNFT(uint256 tokenId, address nftContractAddress) external payable {
        require (listings[nftContractAddress][tokenId].owner != address(0), "Token is not listed");
        require(msg.value >= listings[nftContractAddress][tokenId].price, "Insufficient funds");

        address seller = listings[nftContractAddress][tokenId].owner;
        address owner = listings[nftContractAddress][tokenId].owner;
        uint256 _tokenId = listings[nftContractAddress][tokenId].tokenId;
        uint256 price = listings[nftContractAddress][tokenId].price;
        address _nftContractAddress = listings[nftContractAddress][tokenId].nftContractAddress;

        delete listings[nftContractAddress][tokenId];

        //Pay owner of the NFT
        address payable sellerAddress = payable(seller);
        (bool success, ) = sellerAddress.call{value: msg.value}("");
        if(!success) {
            revert("Transaction failed");
        }

        //Tranfer NFT to the new owner
        IERC721(_nftContractAddress).transferFrom(
            owner,
            msg.sender,
            listings[nftContractAddress][_tokenId].tokenId
        );

        emit Buy(msg.sender, seller, tokenId, _nftContractAddress, price);
    }

    function cancelListing(uint256 tokenId, address nftContractAddress) external {
        require (listings[nftContractAddress][tokenId].owner != address(0), "Token is not listed");
        require(msg.sender == listings[nftContractAddress][tokenId].owner, "Only owner can cancel the listing");

        address _nftContractAddress = listings[nftContractAddress][tokenId].nftContractAddress;

        delete listings[nftContractAddress][tokenId];

        emit Cancel(msg.sender, tokenId, _nftContractAddress);
    }
}