// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155ReceiverUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "../budx-utils/RelayRecipient.sol";
import "../budx-models/struct.sol";
import "./IBudX.sol";

//Mumbai Contract Address:0xA7aB3CA37c021126634a48Fc33e4B0DdA70C24eB
//MainNet Contract Address:
contract BudXNFTControlV4 is Initializable, ERC1155Upgradeable, BaseRelayRecipient, UUPSUpgradeable, OwnableUpgradeable {
    string public name;

    function initialize(address _trustedForwarder) initializer public {
        __ERC1155_init("");
        __Ownable_init();
        __UUPSUpgradeable_init();
        trustedForwarder = _trustedForwarder;
        name = "BUD-Collection";
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    function mint(address creator, string memory newUri, uint256 supply, uint256 tokenId) external {
        _setURI(newUri);
        _mint(creator, tokenId, supply * 2, "");
    }

    function setMetaApproveForAll(address operator, bool approved) public returns (bool)
    {
        _setApprovalForAll(_budMsgSender(), operator, approved);
        return isApprovedForAll(_budMsgSender(), operator);
    }

    function setTrustedForwarder(address _trustedForwarder) public onlyOwner {
        trustedForwarder = _trustedForwarder;
    }

    function versionRecipient() external pure override returns (string memory) {
        return "1";
    }

    function setName() public {
        name = "BUD-Collection-V2";
    }
}
