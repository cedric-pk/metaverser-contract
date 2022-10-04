// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IMetaverserAssets {
    struct MarketItems {
        string name;
        address owner;
        uint256 tokenId;
        uint256 price;
        uint256 supply;
   }

   event AddAssetToMarket(address owner, uint256 tokenId, uint256 supply, uint256 price);
   event BuyAsset(uint256 assetId, address buyer, address seller, uint256 tokenId, uint256 amount, uint256 price);
   event RemoveAssetToMarket(address owner, uint256 tokenId, uint256 supply, uint256 price);
}