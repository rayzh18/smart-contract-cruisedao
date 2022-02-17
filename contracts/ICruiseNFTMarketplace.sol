// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

struct CruiseMembership {
    uint256 tokenId;
    string tokenURI;
    address mintedBy;
    address currentOwner;
    address previousOwner;
    uint256 price;
    bool isForSale;
    bool isWithheld;
    uint16 votingCount;
}