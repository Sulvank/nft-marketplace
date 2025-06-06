# 🛒 NFT Marketplace

**NFT Marketplace** is a simple NFT trading platform built in Solidity. It allows users to list, cancel, and buy ERC721 NFTs using ETH as payment. This project serves as an introduction to smart contract interaction with non-fungible tokens in a marketplace setting.

> **Note**
> This contract uses OpenZeppelin interfaces and is protected against reentrancy with `ReentrancyGuard`.

---

## 🔹 Key Features

* ✅ List NFTs for sale with a custom ETH price.
* ✅ Allow other users to buy listed NFTs.
* ✅ Sellers can cancel their listings.
* ✅ Protected with `nonReentrant` modifiers.
* ✅ Reverts if ETH transfer to seller fails.

---

## 🖉 Contract Flow Diagram

![NFT Marketplace Flow Diagram](diagrams/nft_marketplace_flow.png)

---

## 📄 Deployed Contract

| 🔧 Item                    | 📋 Description                                          |
| -------------------------- | ------------------------------------------------------- |
| **Contract Name**          | `NFTMarketplace`                                        |
| **Deployed Network**       | Local / Foundry                                         |
| **Contract Address**       | *No address available (not deployed to public network)* |
| **Verified on Explorer**   | ❌ No                                                    |
| **Constructor Parameters** | None                                                    |

---

## 🚀 How to Use Locally

### 1️⃣ Clone and Set Up

```bash
git clone <your-repo-url>
cd nft-marketplace
```

### 2️⃣ Install Foundry

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### 3️⃣ Run the Tests

```bash
forge test -vvvv
```

---

## 🧠 Project Structure

```
nft-marketplace/
├── lib/                              # OpenZeppelin libraries (submodules)
├── src/
│   └── NFTMarketplace.sol            # Main marketplace contract
├── test/
│   └── NFTMarketplace.t.sol          # Full test suite
├── diagrams/
│   └── nft_marketplace_flow.png      # Flowchart diagram of marketplace logic
├── foundry.toml                      # Foundry configuration
└── README.md                         # Project documentation
```

---

## 🔍 Contract Summary

### Core Functions

| Function                                    | Description                                             |
| ------------------------------------------- | ------------------------------------------------------- |
| `listNFT(address nft, uint tokenId, price)` | Lists an NFT for sale if caller is the owner            |
| `buyNFT(address nft, uint tokenId)`         | Allows others to buy the NFT by paying the price in ETH |
| `cancelList(address nft, uint tokenId)`     | Lets the seller cancel their listing                    |

### Key Protections

* `nonReentrant` on `buyNFT` and `cancelList` to avoid reentrancy attacks.
* `require(success, "Transfer failed")` ensures seller gets paid or reverts.

---

## 🧪 Tests

The test suite thoroughly validates:

* ✅ NFT minting and ownership assignment
* ✅ Successful NFT listing
* ✅ Rejection if not the owner
* ✅ Purchase with ETH
* ✅ Failure if seller rejects ETH
* ✅ Listing cancellation

---

## 📊 Test Coverage

> Ensures correct behavior in both normal and edge cases.

| File                        | % Functions | % Statements | % Branches |
| --------------------------- | ----------- | ------------ | ---------- |
| `src/NFTMarketplace.sol`    | 100%        | 100%         | 100%       |
| `test/NFTMarketplace.t.sol` | 100%        | 100%         | 100%       |
| **Total**                   | **100%**    | **100%**     | **100%**   |

---

## 📜 License

This project is licensed under the MIT License. See the `LICENSE` file for details.

---

### 🚀 NFT Marketplace: Simple, Secure, and Extensible trading for your NFTs on Ethereum.
