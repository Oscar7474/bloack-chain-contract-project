// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Cross-Border Settlement using Blockchain
/// @notice A smart contract to simulate cross-border payments with reduced fees and enhanced transparency.
contract CrossBorderPayment {
    address public owner; // 合約擁有者
    uint256 public transactionFee; // 手續費率（百分比）

    // 事件，用於記錄交易詳情
    event PaymentProcessed(
        address indexed sender,
        address indexed recipient,
        uint256 amount,
        uint256 fee,
        uint256 exchangeRate
    );

    // 初始化合約，設置手續費
    constructor(uint256 _transactionFee) {
        owner = msg.sender; // 設定合約擁有者為部署者
        transactionFee = _transactionFee; // 設定手續費
    }

    /// @notice 處理跨國付款
    /// @param recipient 收款方地址
    /// @param exchangeRate 匯率（如 1 ETH = X 外幣單位）
    function transferFunds(address payable recipient, uint256 exchangeRate) public payable {
        require(msg.value > 0, "Amount must be greater than zero");
        require(exchangeRate > 0, "Exchange rate must be greater than zero");

        uint256 fee = (msg.value * transactionFee) / 100;
        uint256 amountAfterFee = msg.value - fee;

        require(amountAfterFee > 0, "Amount after fee must be greater than zero");

        // 手續費保留在合約中，不直接轉給 owner
        // 這裡手續費會保留在合約中，直到 owner 提取
        // payable(address(this)).transfer(fee); // 不需要這行，手續費會自動進入合約

        // 將扣除手續費後的款項轉給收款方
        (bool success, ) = recipient.call{value: amountAfterFee}("");
        require(success, "Transfer failed");

        emit PaymentProcessed(msg.sender, recipient, msg.value, fee, exchangeRate);
}


    /// @notice 提取合約中累積的手續費
   function withdrawFees() public {
        require(msg.sender == owner, "Only the owner can withdraw fees");

        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No funds available to withdraw");

        (bool success, ) = payable(owner).call{value: contractBalance}("");
        require(success, "Withdrawal failed");
    }
}

