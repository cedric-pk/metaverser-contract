// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol"; 
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol"; 
import "@openzeppelin/contracts/utils/Strings.sol";
import "./interface/IMetaverserItems.sol";

contract MetaverserItems is ERC1155, IMetaverserItems, Ownable{
    using Counters for Counters.Counter;

    uint256 totalSupply;
    string public name;
    string public symbol;
    Counters.Counter private tokenCounter;


    mapping(uint256 => Assets) public gameAssets; 
    mapping(address => bool) private whitelist;
    
    constructor() ERC1155("https://assets.metaverser.me/Items/token-{id}.json") {
        name = "Metaverser Items";
        symbol = "MITM";
        setWhitelist(owner(), true);
    }

    modifier whitelisted(){
        require(whitelist[msg.sender] , "You are not whitelisted");
        _;
    }

    function mint(address _to, uint256 _amount, string memory _name) public whitelisted {
        uint256 tokenId = tokenCounter.current();

        gameAssets[tokenId] = Assets(_name, _amount) ;

        _mint(_to, tokenId, _amount, '');

        totalSupply = _amount + totalSupply;
        tokenCounter.increment();
    }

    function getTokensByOwner(address _user) public view returns(Assets[] memory){
        uint256 totalToken = tokenCounter.current() ;
        Assets[] memory userAssets = new Assets[](totalToken);
        for (uint256 i = 0 ; i < totalToken ; i ++) {
           userAssets[i]= Assets(gameAssets[i].name, super.balanceOf(_user, i));
        }
        return userAssets;
    }   

    function uri(uint256 _tokenId) override public pure returns (string memory) {
        return string(
            abi.encodePacked(
                "https://assets.metaverser.me/Items/token-",  Strings.toString(_tokenId),".json"
            )
        );
    }

    function getTokenName(uint256 _tokenId) public view returns(string memory) {
        return gameAssets[_tokenId].name;
    }

    function getTokenCount() public view returns(uint256) {
        return tokenCounter.current();
    }

    function setWhitelist(address _addr, bool _val) public onlyOwner {
        whitelist[_addr] = _val;
    }
}