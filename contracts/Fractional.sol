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
}