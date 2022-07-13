// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./enum.sol";

library Structs {
    struct MarketItem {
        uint256 itemId;
        uint256 tokenId;
        address nftContract;
        address payable creator;
        address payable owner;
        address payable seller;
        Enums.ListType listType;
        uint256 royalty;
        uint256 price;
        uint256 supply;
        string uid;
    }

    struct PublishReq {
        bool isMint;
        string uid;
        string md5;
        uint256 budActId;
        Structs.MintReq mintReq;
        Structs.ListReq listReq;
    }

    struct MintReq {
        string newUri;
        uint256 supply;
    }

    struct ListReq {
        address nftContract;
        uint256 tokenId;
        uint256 price;
        uint256 royalty;
        address payable creatorAddr;
        uint256 supply;
    }

    struct SellMarketItemReq {
        address nftContract;
        uint256 tokenId;
        string uid;
        uint256 budActId;
    }
}
