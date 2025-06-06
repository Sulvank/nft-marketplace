// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import "forge-std/Test.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "../src/NFTMarketplace.sol";

contract MockNFT is ERC721 {

    constructor() ERC721("MockNFT", "MNFT") {}

    function mint(address to_, uint256 tokenId_) external {
        _mint(to_, tokenId_);
 
    }
}

contract RevertingReceiver {
    function listOnMarketplace(address nftAddress, uint256 tokenId, address marketplace) external {
        IERC721(nftAddress).approve(marketplace, tokenId);
        NFTMarketplace(marketplace).listNFT(nftAddress, tokenId, 1 ether);
    }

    receive() external payable {
        revert("Refusing ETH");
    }
}

contract NFTMarketplaceTest is Test {
    
    NFTMarketplace marketplace;
    MockNFT nft;
    address deployer = vm.addr(1);
    address user = vm.addr(2);
    uint256 tokenId = 0;

    function setUp() public {
        vm.startPrank(deployer);
        marketplace = new NFTMarketplace();
        nft = new MockNFT();
        vm.stopPrank();

        vm.startPrank(user);
        nft.mint(user, tokenId);
        vm.stopPrank();
    }

    function testMintNFT() public view {
        address ownerOf = nft.ownerOf(tokenId);
        assert(ownerOf == user);
    }

    function testShouldRevertIfPriceIsZero() public {
        vm.startPrank(user);
        vm.expectRevert("Price must be greater than zero");
        marketplace.listNFT(address(nft), tokenId, 0);
        vm.stopPrank();
    }

    function testShouldRevertIfNotOwner() public {
        vm.startPrank(user);

        address user2_ = vm.addr(3);
        uint256 tokenId_ = 1;
        nft.mint(user2_, tokenId_); // Mint NFT to another user

        vm.expectRevert("You must own the NFT to list it");
        marketplace.listNFT(address(nft), tokenId_, 1 ether);
        vm.stopPrank();
    }

    function testShouldListNFT() public{
        vm.startPrank(user);

        (address sellerBefore,,,) = marketplace.listing(address(nft), tokenId);
        marketplace.listNFT(address(nft), tokenId, 1 ether);
        (address sellerAfter,,,) = marketplace.listing(address(nft), tokenId);
        assert(sellerBefore == address(0) && sellerAfter == user);

        vm.stopPrank();
    }

    function testShouldRevertCanceListIfNotOwner() public {
        vm.startPrank(user);

        (address sellerBefore,,,) = marketplace.listing(address(nft), tokenId);
        marketplace.listNFT(address(nft), tokenId, 1 ether);
        (address sellerAfter,,,) = marketplace.listing(address(nft), tokenId);
        assert(sellerBefore == address(0) && sellerAfter == user);

        vm.stopPrank();

        address user2_ = vm.addr(3);
        vm.startPrank(user2_);

        vm.expectRevert("You are not the seller of this NFT");
        marketplace.cancelList(address(nft), tokenId);
        vm.stopPrank();
    }

    function testCancelListShouldWorkCorrectly() public {
        vm.startPrank(user);

        (address sellerBefore,,,) = marketplace.listing(address(nft), tokenId);
        marketplace.listNFT(address(nft), tokenId, 1 ether);
        (address sellerAfter,,,) = marketplace.listing(address(nft), tokenId);
        assert(sellerBefore == address(0) && sellerAfter == user);
        marketplace.cancelList(address(nft), tokenId);

        (address sellerAfter2,,,) = marketplace.listing(address(nft), tokenId);
        assert(sellerAfter2 == address(0));
        vm.stopPrank();
    }

    function testShouldRevertIfNFTNotListed() public {
        vm.startPrank(user);
        vm.expectRevert("This NFT is not listed for sale");
        marketplace.buyNFT(address(nft), tokenId);
        vm.stopPrank();
    }

    function testShouldRevertIfNotSufficientFunds() public {
        vm.startPrank(user);
        marketplace.listNFT(address(nft), tokenId, 1 ether);
        vm.expectRevert("Insufficient funds sent");
        marketplace.buyNFT(address(nft), tokenId);
        vm.stopPrank();
    }

    function testShouldRevertIfBuyerIsSeller() public {
        vm.startPrank(user);
        uint256 price = 1 ether;
        marketplace.listNFT(address(nft), tokenId, price);
        vm.deal(user, price);
        vm.expectRevert("You cannot buy your own NFT");
        marketplace.buyNFT{ value: price}(address(nft), tokenId);
        vm.stopPrank();
    }

    function testShouldRevertIfETHTransferFails() public {
        // Usamos un nuevo tokenId que no fue usado en el setUp()
        uint256 newTokenId_ = 1;
        uint256 price_ = 1 ether;
        // Deploy contract that rejects ETH
        RevertingReceiver seller_ = new RevertingReceiver();

        // Mint NFT to the seller contract (desde una cuenta válida)
        vm.prank(deployer); // cualquier dirección válida
        nft.mint(address(seller_), newTokenId_);

        // List the NFT from within the seller contract
        vm.prank(address(seller_));
        seller_.listOnMarketplace(address(nft), newTokenId_, address(marketplace));

        // Simulate a buyer
        address buyer_ = vm.addr(2);
        vm.deal(buyer_, price_);
        vm.startPrank(buyer_);

        vm.expectRevert("Transfer failed");
        marketplace.buyNFT{ value: price_ }(address(nft), newTokenId_);

        vm.stopPrank();
    }



    function testBuyNFTShouldWorkCorrectly() public {
        vm.startPrank(user);
        uint256 price = 1 ether;
        nft.approve(address(marketplace), tokenId);
        (address sellerBefore,,,) = marketplace.listing(address(nft), tokenId);
        marketplace.listNFT(address(nft), tokenId, price);
        (address sellerAfter,,,) = marketplace.listing(address(nft), tokenId);
        assert(sellerBefore == address(0) && sellerAfter == user);
        vm.stopPrank();


        address user2_ = vm.addr(3);
        vm.startPrank(user2_);
        vm.deal(user2_, price);

        uint256 balanceBefore = address(user).balance;
        address ownerBefore = nft.ownerOf(tokenId);
        (address sellerBefore2,,,) = marketplace.listing(address(nft), tokenId);
        marketplace.buyNFT{ value: price }(address(nft), tokenId);
        (address sellerAfter2,,,) = marketplace.listing(address(nft), tokenId);
        address ownerAfter = nft.ownerOf(tokenId);
        uint256 balanceAfter = address(user).balance;

        assert(sellerBefore2 == user && sellerAfter2 == address(0));
        assert(ownerBefore == user && ownerAfter == user2_);
        assert(balanceAfter == balanceBefore + price);
        vm.stopPrank();
    }
}