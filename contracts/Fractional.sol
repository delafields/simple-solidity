// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

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