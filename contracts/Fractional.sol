// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTFractions is ERC20, ERC20Burnable {
    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        uint256 totalFractionalTokens,
        address nftOwnerAddress
    ) payable ERC20(tokenName, tokenSymbol) {
        _mint(nftOwnerAddress, totalFractionalTokens);
    }

    function burnFrom(uint256 numToBurn) public {
        burn(numToBurn);
    }
}

contract FractionalFactory {
    struct FractionalDeed {
        ERC721 nftContract;
        uint256 tokenId;
        uint256 totalFractionalTokens;
        NFTFractions tokenContract;
    }

    uint256 internal deedId = 1; // 1 for optimizaish

    mapping(uint256 => FractionalDeed) getDeed;

    function fractionalize(
        ERC721 _nftContract,
        uint256 _tokenId,
        uint256 _tokenSupply,
        string memory _tokenName,
        string memory _tokenSymbol
    ) public payable returns (uint256) {
        NFTFractions fractionalContract = new NFTFractions(
            _tokenName, 
            _tokenSymbol, 
            _tokenSupply, 
            msg.sender
        );

        FractionalDeed memory deed = FractionalDeed({
            nftContract: _nftContract,
            tokenId: _tokenSupply,
            totalFractionalTokens: _tokenSupply,
            tokenContract: fractionalContract
        });

        getDeed[deedId] = deed;

        _nftContract.transferFrom(msg.sender, address(this), _tokenId);

        return deedId++;
    }

    function unfractionalize(uint256 _deedId) public {
        FractionalDeed memory deed = getDeed[_deedId];

        // ensure this has been fractionalized
        require(address(deed.tokenContract) != address(0), "this has not yet been fractionalized");

        // remove mapping
        delete getDeed[_deedId];

        deed.tokenContract.burnFrom(deed.totalFractionalTokens);
        deed.nftContract.transferFrom(address(this), msg.sender, deed.tokenId);
    }

    // interface allowing the contract to accept ERC721s
    // https://ethereum.stackexchange.com/questions/48796/whats-the-point-of-erc721receiver-sol-and-erc721holder-sol-in-openzeppelins-im
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public payable returns (bytes4) {
        return this.onERC721Received.selector;
    }
}