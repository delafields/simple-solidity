// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./Storage.sol";

// great stack convo about this subject: https://ethereum.stackexchange.com/questions/2404/upgradeable-smart-contracts
// alternative approach: https://gist.github.com/Arachnid/4ca9da48d51e23e5cfe0f0e14dd6318f

/**
 * @title Upgradeable Contracts
 * @author delafields
 * @notice This a master contract that update/call new versions
 * @dev this is purely experimental
 */
contract MasterContract is Storage {

    address private owner = msg.sender;
    address public currentVersionAddress;
    string  public currentReleaseNumber;

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can call this");
        _;
    }

    event NewVersionReleased(
        address newVersionContractAddress, 
        string  newReleaseNumber
    );

    function setVersion(
        address _newVersionContractAddress,
        string  calldata _newReleaseNumber
    ) external onlyOwner
    {
        currentVersionAddress = _newVersionContractAddress;
        currentReleaseNumber  = _newReleaseNumber;
        
        emit NewVersionReleased(
            _newVersionContractAddress, 
            _newReleaseNumber
        );
    }

    function getCurrentVersion() 
        public 
        view
        returns(address _currentVersionAddress, string memory _currentReleaseNumber)
    {
        return (currentVersionAddress, currentReleaseNumber);
    }

    // this triggers the newest implementation's methods
    fallback() external onlyOwner {
        (bool success, ) = currentVersionAddress.delegatecall(msg.data);
        require(success, "call to current version failed");
    }
}