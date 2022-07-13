// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../budx-models/struct.sol";

interface IBudXData {
    function createItem(Structs.MarketItem memory item) external returns (uint256);

    function deleteItem(uint256 itemId) external;

    function getItem(uint256 itemId) external view returns (Structs.MarketItem memory);

    function getItemId(address nftContract, uint256 tokenId) external view returns (uint256);

    function deleteItemId(address nftContract, uint256 tokenId) external;

    function newTokenId() external returns (uint256);
}

interface IBudXNft {
    function mint(address creator, string memory newUri, uint256 supply, uint256 tokenId) external;
}
