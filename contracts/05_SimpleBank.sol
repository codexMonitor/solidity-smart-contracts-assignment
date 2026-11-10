// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title SimpleBank
/// @notice Per-user ETH balances with re-entrancy-safe withdrawals
contract SimpleBank {
    mapping(address => uint256) private balances;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    function deposit() public payable {
        require(msg.value > 0, "Deposit must be greater than 0");
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public {
        // 1. CHECKS
        require(amount > 0, "Amount must be greater than 0");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // 2. EFFECTS (update state BEFORE sending ETH)
        balances[msg.sender] -= amount;

        // 3. INTERACTIONS (external call last)
        (bool ok, ) = payable(msg.sender).call{value: amount}("");
        require(ok, "ETH transfer failed");

        emit Withdrawn(msg.sender, amount);
    }

    function myBalance() public view returns (uint256) {
        return balances[msg.sender];
    }

    function bankTotal() public view returns (uint256) {
        return address(this).balance;
    }
}