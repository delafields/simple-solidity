// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import { ERC20 } from "https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC20.sol";
import { ERC721 } from"https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC721.sol";

/**
 * @title Fractional
 * @author delafields
 * @notice This is a mini implementation of Fractional 
 */
 contract Fractional {

     struct Vault {
         address _721Address;
     }

     function fractionalize (
         address _721Address,
         string _name,
         string symbol,
         uint _amount
     ) public payable returns (uint)
     {

     }

     function unfractionalize (

     )
     {

     }

 }