// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./Storage.sol";

contract FunctionalityV1 is Storage {

    event EchoFizz(string question, bool canI);

    function fizz() external {
        ICanFizz = true;
        emit EchoFizz("Can I fizz?", ICanFizz);
    }

}