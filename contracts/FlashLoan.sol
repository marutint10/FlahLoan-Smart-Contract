// SPDX-License-Identifier: MIT
pragma solidity^0.8.13;

import "./Token.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IReceiver {
    function receiveTokens(address tokenAddress, uint256 amount) external;
}

contract FlashLoan is ReentrancyGuard {
    using SafeMath for uint256;

    Token public token;
    uint256 public poolBalance;

    constructor(address tokenAddress) {
        require(tokenAddress != address(0), "Token address cannot be zero");
        token = Token(tokenAddress);
    }

    function depositTokens(uint256 amount) external nonReentrant {
        require(amount > 0, "Must deposit at least one token");
        token.transferFrom(msg.sender, address(this), amount);
        poolBalance = poolBalance.add(amount);
    }

    function flashLoan(uint256 borrowAmount) external nonReentrant {
        require(borrowAmount > 0, "Must borrow at least one token");

        uint256 balanceBefore = token.balanceOf(address(this));
        require(balanceBefore >= borrowAmount, "Not enough tokens in pool");
        assert(poolBalance == balanceBefore);

        token.transfer(msg.sender, borrowAmount);

        IReceiver(msg.sender).receiveTokens(address(token), borrowAmount);

        uint256 balanceAfter = token.balanceOf(address(this));
        require(balanceAfter >= balanceBefore, "Flash loan hasn't been paid back");
    }

}