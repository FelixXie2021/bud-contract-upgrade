// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

abstract contract Runnable {
    bool private running;
    mapping(address => bool) internal accessMapping;
    constructor() {
        running = true;
    }

    modifier isRunnable() {
        require(running, "Contract suspension!");
        _;
    }

    function _switchRunnable(bool isRun) internal {
        running = isRun;
    }

    modifier isAccess(address addr) {
        require(accessMapping[addr], "This contract does not have permission to call!");
        _;
    }

    function addAccess(address newContract) internal {
        accessMapping[newContract] = true;
    }

    function removeAccess(address newContract) internal {
        accessMapping[newContract] = false;
    }
}
