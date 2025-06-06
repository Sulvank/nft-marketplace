// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract NFTMarketplace is ReentrancyGuard {

    struct Listing {
        address seller;
        address nftAddress;
        uint256 tokenId;
        uint256 price;
    }

    mapping(address => mapping(uint256 => Listing)) public listing;

    // Events
    event NFTListed(address indexed seller, address indexed nftAddress, uint256 indexed tokenId, uint256 price);
    event NFTListingCancelled(address indexed seller, address indexed nftAddress, uint256 indexed tokenId);
    event NFTSold(address indexed buyer, address indexed seller,  address indexed nftAddress, uint256 tokenId, uint256 price);
    constructor() {
        // Initialize the contract
    }

    // List NFTs
    function listNFT(address nftAddress_, uint256 tokenId_, uint256 price_) external {
        require(price_ > 0, "Price must be greater than zero");
        address owner_ = IERC721(nftAddress_).ownerOf(tokenId_);
        require(owner_ == msg.sender, "You must own the NFT to list it");

        Listing memory listing_ = Listing({
            seller: msg.sender,
            nftAddress: nftAddress_,
            tokenId: tokenId_,
            price: price_
        });


        listing[nftAddress_][tokenId_] = listing_;

        emit NFTListed(msg.sender, nftAddress_, tokenId_, price_);
    }

    // Buy NFTs
    function buyNFT(address nftAddress_, uint256 tokenId_) external payable nonReentrant {
        Listing memory listing_ = listing[nftAddress_][tokenId_];
        require(listing_.price > 0, "This NFT is not listed for sale");
        require(msg.value >= listing_.price, "Insufficient funds sent");

        require(listing_.seller != msg.sender, "You cannot buy your own NFT");

        // Remove the listing
        delete listing[nftAddress_][tokenId_];

        // Transfer the NFT to the buyer
        IERC721(nftAddress_).safeTransferFrom(listing_.seller, msg.sender, tokenId_);

        (bool success, ) = listing_.seller.call{value: msg.value}("");
        require(success, "Transfer failed");

        emit NFTSold(msg.sender, listing_.seller, nftAddress_, tokenId_, listing_.price);
    }


    // Cancel List
    function cancelList(address nftAddress_, uint256 tokenId_) external nonReentrant {
        Listing memory listing_ = listing[nftAddress_][tokenId_];
        require(listing_.seller == msg.sender, "You are not the seller of this NFT");

        delete listing[nftAddress_][tokenId_];

        emit NFTListingCancelled(msg.sender, nftAddress_, tokenId_);
    }
}