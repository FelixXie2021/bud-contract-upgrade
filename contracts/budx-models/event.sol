// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./enum.sol";
import "./struct.sol";

library Events {
    //addresses = [owner, creator, seller]
    //0x694f1acfe49fa8ae2825ad061f59d21f7fa69ecc2f8bf0045cc449ee588dc945
    event BudXDCPublish(
        uint256 indexed budActId,
        address indexed nftContract,
        uint256 indexed tokenId,
        uint256 itemId,
        address[3] addresses,
        uint256 price,
        uint256 royalty,
        uint256 supply,
        uint256 balance,
        string uid,
        string md5
    );

    event BudXDCList(
        uint256 indexed budActId,
        address indexed nftContract,
        uint256 indexed tokenId,
        uint256 itemId,
        address[3] addresses,
        uint256 price,
        uint256 royalty,
        uint256 supply,
        uint256 balance,
        string uid
    );

    //price = [sellerPrice, royaltyPrice, serverPrice]
    //0xdec328dc188782f01cf575fcde464baf39ab54f1cd791d03f9f28ab0ad6c3ca6
    event BudXDCSell(
        uint256 indexed budActId,
        uint256 tokenId,
        address nftContract,
        address[3] addresses,
        uint256[3] price,
        string uid
    );
}
