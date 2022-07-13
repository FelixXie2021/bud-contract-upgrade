// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./../budx-models/struct.sol";
import "./../budx-utils/runnable.sol";

//Mumbai Contract Address:0x37664b827Ad689D05A418CFDFa3DaAB977eD2024
//MainNet Contract Address:
contract BudXData is Ownable, Runnable {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds; //marketItem 的 Id
    Counters.Counter private _tokenIds; //nft 的 Id

    mapping(uint256 => Structs.MarketItem) private itemIdToMarketItemMapping;
    mapping(address => mapping(uint256 => uint256)) private tokenIdToItemIdMapping;

    function createItem(Structs.MarketItem memory item) external isRunnable isAccess(msg.sender) returns (uint256) {
        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        item.itemId = itemId;
        itemIdToMarketItemMapping[itemId] = item;
        tokenIdToItemIdMapping[item.nftContract][item.tokenId] = itemId;

        return itemId;
    }

    function deleteItem(uint256 itemId) isRunnable isAccess(msg.sender) external {
        delete itemIdToMarketItemMapping[itemId];
    }

    function getItem(uint256 itemId) external view returns (Structs.MarketItem memory)
    {
        return itemIdToMarketItemMapping[itemId];
    }

    function getItemId(address nftContract, uint256 tokenId) external view returns (uint256)
    {
        return tokenIdToItemIdMapping[nftContract][tokenId];
    }

    function deleteItemId(address nftContract, uint256 tokenId) external isRunnable isAccess(msg.sender) {
        delete tokenIdToItemIdMapping[nftContract][tokenId];
    }

    function newTokenId() external isAccess(msg.sender) returns (uint256) {
        _tokenIds.increment();
        return _tokenIds.current();
    }

    function getCurrentItemId() external view returns (uint256) {
        return _itemIds.current();
    }

    function getCurrentTokenId() external view returns (uint256) {
        return _tokenIds.current();
    }

    ///control
    function switchRunnable(bool isRun) public onlyOwner {
        _switchRunnable(isRun);
    }
    function addContractAccess(address newContract) public onlyOwner {
        addAccess(newContract);
    }
    function removeContractAccess(address newContract) public onlyOwner {
        removeAccess(newContract);
    }
    function getContractAccess(address addr) public view returns (bool) {
        return accessMapping[addr];
    }
    ///control
}
