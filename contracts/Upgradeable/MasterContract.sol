// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

// make this ownable
contract MasterContract {

    address public owner = msg.sender;
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

    // this should trigger the newest implementation's methods
    fallback() external onlyOwner {
        (bool success, ) = currentVersionAddress.delegatecall(msg.data);
        require(success, "call to current version failed");
    }
}