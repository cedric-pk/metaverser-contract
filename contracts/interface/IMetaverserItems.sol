// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol"; 

interface IMetaverserItems is IERC1155 {
    struct Assets {
        string name;
        uint256 supply;
    }

    function mint(address _to, uint256 _amount, string memory _name) external;

    function getTokenName(uint256 _tokenId) external view returns(string memory);

    function getTokenCount() external view returns(uint256);
}