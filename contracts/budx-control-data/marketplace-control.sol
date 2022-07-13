// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./../budx-utils/runnable.sol";
import "./IBudX.sol";
import "../budx-models/struct.sol";
import "../budx-models/event.sol";
import "../budx-utils/RelayRecipient.sol";

//Mumbai Contract Address:0xC2aE438a0808d50faa53004707EBeeC026Ac85Bd
//MainNet Contract Address:
contract BudXMarketControl is ERC1155Holder, Ownable, Runnable, ReentrancyGuard, BaseRelayRecipient
{
    string public name = "BUD-Collection";

    address payable contractOwner;
    uint256 public royaltyFeeRate;
    uint256 public serviceFeeBase;
    uint256 public serviceFeeRate;

    IBudXData private dataContract;
    IBudXNft private nftContract;
    address nftContractAddress;

    constructor(address _trustedForwarder, address _dataContract, address _nftContract) payable  {
        trustedForwarder = _trustedForwarder;
        contractOwner = payable(_budMsgSender());
        royaltyFeeRate = 10000;
        serviceFeeBase = 3;
        serviceFeeRate = 10;
        dataContract = IBudXData(_dataContract);
        nftContract = IBudXNft(_nftContract);
        nftContractAddress = _nftContract;
    }

    function publishMarketItem(Structs.PublishReq memory publishReq) public payable nonReentrant isRunnable {
        require(bytes(publishReq.uid).length != 0, "uid is empty!");
        if (publishReq.isMint) {
            require(bytes(publishReq.mintReq.newUri).length != 0, "uri is empty!");
            require(publishReq.mintReq.supply > 0, "supply must more than 0!");
            require(nftContractAddress == publishReq.listReq.nftContract, "invalid nftContractAddress!");

            uint256 tokenId = dataContract.newTokenId();
            nftContract.mint(_budMsgSender(), publishReq.mintReq.newUri, publishReq.mintReq.supply, tokenId);
            uint256 itemId = list(nftContractAddress, tokenId, publishReq.listReq.price, publishReq.listReq.royalty, payable(_budMsgSender()), publishReq.uid, publishReq.mintReq.supply);

            address[3] memory addressArray = [address(_budMsgSender()), _budMsgSender(), _budMsgSender()];
            emit Events.BudXDCPublish(
                publishReq.budActId,
                nftContractAddress,
                tokenId,
                itemId,
                addressArray,
                publishReq.listReq.price,
                publishReq.listReq.royalty,
                publishReq.mintReq.supply,
                publishReq.mintReq.supply,
                publishReq.uid,
                publishReq.md5
            );
        } else {
            uint256 itemId = list(publishReq.listReq.nftContract, publishReq.listReq.tokenId, publishReq.listReq.price, publishReq.listReq.royalty, publishReq.listReq.creatorAddr, publishReq.uid, publishReq.listReq.supply);
            address[3] memory addressArray = [address(_budMsgSender()), publishReq.listReq.creatorAddr, _budMsgSender()];
            emit Events.BudXDCList(
                publishReq.budActId,
                publishReq.listReq.nftContract,
                publishReq.listReq.tokenId,
                itemId,
                addressArray,
                publishReq.listReq.price,
                publishReq.listReq.royalty,
                publishReq.listReq.supply,
                publishReq.listReq.supply,
                publishReq.uid
            );
        }
    }

    function list(address _nftContract, uint256 tokenId, uint256 price, uint256 royalty, address payable creatorAddr, string memory uid, uint256 supply) private returns (uint256) {
        require(price > 0, "Price must be at least 1 wei");
        uint256 itemId = dataContract.getItemId(_nftContract, tokenId);
        require(itemId == 0, "This nft has already listed!");

        Structs.MarketItem memory item = Structs.MarketItem(
            0,
            tokenId,
            _nftContract,
            creatorAddr,
            payable(_budMsgSender()),
            payable(_budMsgSender()),
            Enums.ListType.FIXED_PRICE,
            royalty,
            price,
            supply,
            uid
        );
        uint256 newItemId = dataContract.createItem(item);
        return newItemId;
    }

    function sellMarketItem(Structs.SellMarketItemReq memory req) public payable nonReentrant isRunnable {
        uint256 itemId = dataContract.getItemId(req.nftContract, req.tokenId);
        require(itemId != 0, "No item found");
        Structs.MarketItem memory itemInfo = dataContract.getItem(itemId);
        require(
            msg.value == itemInfo.price,
            "Please submit the asking price in order to complete the purchase"
        );

        bool ok = true;
        uint256 temp;

        (ok, temp) = SafeMath.tryMul(itemInfo.price, itemInfo.royalty);
        require(ok, "royalty compute error");
        uint256 royaltyPrice;
        (ok, royaltyPrice) = SafeMath.tryDiv(temp, royaltyFeeRate);
        require(ok, "royaltyPrice compute error");

        (ok, temp) = SafeMath.tryMul(itemInfo.price, serviceFeeBase);
        require(ok, "serviceFeeBase compute error");
        uint256 serverPrice;
        (ok, serverPrice) = SafeMath.tryDiv(temp, serviceFeeRate);
        require(ok, "servicePrice compute error");

        require(
            (itemInfo.price - royaltyPrice - serverPrice) > 0,
            "sellerPrice compute error"
        );
        uint256 sellerPrice = itemInfo.price - royaltyPrice - serverPrice;

        payable(contractOwner).transfer(serverPrice);
        itemInfo.seller.transfer(sellerPrice);
        itemInfo.creator.transfer(royaltyPrice);

        IERC1155(req.nftContract).safeTransferFrom(itemInfo.seller, _budMsgSender(), req.tokenId, 1, "");

        dataContract.deleteItem(itemInfo.itemId);
        dataContract.deleteItemId(req.nftContract, req.tokenId);

        uint256[3] memory priceArray = [sellerPrice, royaltyPrice, serverPrice];
        address[3] memory addressArray = [address(_budMsgSender()), itemInfo.creator, itemInfo.seller];
        emit Events.BudXDCSell(
            req.budActId,
            itemInfo.tokenId,
            itemInfo.nftContract,
            addressArray,
            priceArray,
            req.uid
        );
    }

    function switchRunnable(bool isRun) public onlyOwner {
        _switchRunnable(isRun);
    }

    function setTrustedForwarder(address _trustedForwarder) public onlyOwner {
        trustedForwarder = _trustedForwarder;
    }

    function versionRecipient() external pure override returns (string memory) {
        return "1";
    }
}