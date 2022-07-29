pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

    event SellTokens(address seller, uint256 amountOfETH, uint256 amountOfTokens);

    YourToken public yourToken;

    uint256 public constant tokensPerEth = 100;

    constructor(address tokenAddress) {
        yourToken = YourToken(tokenAddress);
        transferOwnership(msg.sender);
    }

    function buyTokens() public payable {
        require(msg.value > 0, "You must send some ETH");
        uint256 amountOfTokens = msg.value * tokensPerEth;
        yourToken.transfer(msg.sender, amountOfTokens);
        emit BuyTokens(msg.sender, msg.value, amountOfTokens);
    }

    function sellTokens(uint256 _amount) public {
        require(_amount > 0, "You must send some tokens");
        uint256 amountOfEth = _amount / tokensPerEth;
        require(amountOfEth <= address(this).balance, "Contract as not enough ETH to sell");
        yourToken.transferFrom(msg.sender, address(this), _amount);
        (bool success, ) = msg.sender.call{value: amountOfEth}("");
        require(success, "Failed to sell tokens");
        emit SellTokens(msg.sender, amountOfEth, _amount);
    }

    function withdraw(uint256 _amout) onlyOwner public {
        require(_amout >= address(this).balance, "Contract as not enough ETH to withdraw");
        (bool success, ) = msg.sender.call{value: _amout}("");
        require(success, "Failed to withdraw fund");
    }

}
