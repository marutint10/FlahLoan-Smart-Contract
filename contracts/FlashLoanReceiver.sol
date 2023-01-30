// SPDX-License-Identifier: Unlicense
pragma solidity^0.8.13;

import "./Token.sol";
import "./FlashLoan.sol";

contract FlashLoanReceiver {

    FlashLoan private pool;
    address private owner;

    event LoanReceived(address token, uint256 amount);

    constructor(address poolAddress) public {
        pool = FlashLoan(poolAddress);
        owner = msg.sender;
    }

    function receiveTokens(address tokenAddress, uint256 amount) external {
        require(msg.sender == address(pool), "Sender must be pool");
        emit LoanReceived(tokenAddress, amount);
        require(Token(tokenAddress).transfer(msg.sender, amount), "Transfer of tokens failed");
    }

    function executeFlashLoan(uint256 amount) external {
        require(msg.sender == owner, "Only owner can execute flash loan");
        pool.flashLoan(amount);
    }
}