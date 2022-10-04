// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/IMetaverserItems.sol";
import "./interface/IMetaverserAssets.sol";
 
contract MarketplaceAssets is IMetaverserAssets, Ownable {

    IERC20 public MTVTToken;
    IMetaverserItems public itemsContract;

    uint256 public daoPercent = 4;
    uint256 public minerPercent = 1;
    uint256 public assetsCount;

    address public daoAddr;
    address public minerAddr;
    bool public isPaused;

    mapping(address => bool) private whitelist;
    mapping(uint256 => MarketItems) public gameAssets;

    constructor(IERC20 _erc20, IMetaverserItems _itemsContract) {
        itemsContract = _itemsContract;
        MTVTToken = _erc20;
        isPaused = false;
        daoAddr = msg.sender;
        minerAddr = msg.sender;
        whitelist[msg.sender] = true;
    }

    modifier tokenOwnerAccess(uint256 tokenId, uint256 supply) {
        require(itemsContract.balanceOf(msg.sender, tokenId) >= supply, 'Not enough token');
        _;
    }
    
    modifier openMarket() {
        require(!isPaused , "Market is paused");
        _;
    }

    modifier whitelisted(){
        require(whitelist[msg.sender] , "You are not whitelisted");
        _;
    }


    function addAssetToMarket(uint256 tokenId, uint256 supply, uint256 price) public tokenOwnerAccess(tokenId, supply) openMarket whitelisted {
        require(tokenId < itemsContract.getTokenCount() , 'Invalid tokenId') ;
        require(price > 0 , 'Invalid price');
        require(supply > 0 , 'Invalid supply');
        require(itemsContract.isApprovedForAll(msg.sender, address(this)), 'You must approve all tokens to contract');

        itemsContract.safeTransferFrom(msg.sender, address(this), tokenId, supply, "");
        gameAssets[assetsCount] = MarketItems(itemsContract.getTokenName(tokenId), msg.sender, tokenId, price, supply);
        assetsCount ++;

        emit AddAssetToMarket(msg.sender, tokenId, supply, price);
    }

    function buyAsset(uint256 assetId, uint256 amount) public openMarket {
        require(assetId < assetsCount , 'Invalid assetId');
        require(amount > 0  ,'Invalid amount');

        uint256 totalPrice = gameAssets[assetId].price * amount;
        uint256 DAOTax = totalPrice * daoPercent / 100;
        uint256 MinersTax = totalPrice * minerPercent / 100;

        if(gameAssets[assetId].owner != owner()) {
            MTVTToken.transferFrom(msg.sender, daoAddr, DAOTax);
            MTVTToken.transferFrom(msg.sender, minerAddr, MinersTax);
        }

        MTVTToken.transferFrom(msg.sender, gameAssets[assetId].owner , totalPrice);
        itemsContract.safeTransferFrom(address(this), msg.sender, gameAssets[assetId].tokenId, amount, "");
        gameAssets[assetId].supply = gameAssets[assetId].supply - amount;

        emit BuyAsset(assetId, msg.sender, gameAssets[assetId].owner, gameAssets[assetId].tokenId, amount, gameAssets[assetId].price);
    }

    function removeAssetFromMarket(uint256 assetId, uint256 amount) public openMarket {
        require(assetId < assetsCount , 'Invalid assetId');
        require(amount > 0  ,'Invalid amount');
        require(gameAssets[assetId].owner != msg.sender  ,'You are not owner');

        itemsContract.safeTransferFrom(address(this), msg.sender, gameAssets[assetId].tokenId, amount, "");
        gameAssets[assetId].supply = gameAssets[assetId].supply - amount;

        emit RemoveAssetToMarket(msg.sender, gameAssets[assetId].tokenId, amount, gameAssets[assetId].price);
    }

    function setPause(bool _pause) public onlyOwner {
        isPaused = _pause;
    }

    function setDAOAddr(address _addr) public onlyOwner {
        daoAddr = _addr;
    }

    function setMinersAddress(address _addr) public onlyOwner {
        minerAddr = _addr;
    }

    function setWhitelist(address _addr, bool _val) public onlyOwner {
        whitelist[_addr] = _val;
    }
}