// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

// make this ownable
contract MasterContract {

    address public currentVersionAddress;
    string  public currentReleaseNumber;

    event NewVersionReleased(
        address newVersionContractAddress, 
        string  newReleaseNumber
    );

    // make ownable
    function setVersion(
        address _newVersionContractAddress,
        string  calldata _newReleaseNumber
    ) external 
    {
        currentVersionAddress = _newVersionContractAddress;
        currentReleaseNumber  = _newReleaseNumber;
        
        emit NewVersionReleased(
            _newVersionContractAddress, 
            _newReleaseNumber
        );
    }

    // this should trigger the newest implementation
    fallback() external {
        (bool success, ) = currentVersionAddress.delegatecall(msg.data);
        require(success, "call to current version failed");
    }
}