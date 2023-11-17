// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AirdropContract is Ownable {
    IERC20 private _token;
    mapping(address => bool) private _claimed;

    event AirdropClaimed(address indexed recipient, uint256 amount);
    event EtherWithdrawn(address indexed owner, uint256 amount);
    event TokenWithdrawn(address indexed owner, uint256 amount);

    constructor(address tokenAddress) {
        _token = IERC20(tokenAddress);
    }

    function claimAirdrop() external payable {
        require(!_claimed[msg.sender], "Airdrop already claimed");
        
        // Add your airdrop amount calculation logic here
        uint256 airdropAmount = 1000; // Adjust this based on your requirements
        
        // Add automatic fee calculation logic here
        uint256 claimFee = 999 * 10**12; // airdrop amount as fee
        
        // Ensure sent value covers the fee
        require(msg.value >= claimFee, "Insufficient fee");

        // Transfer airdrop tokens to the recipient
        _token.transfer(msg.sender, airdropAmount);

        // Transfer fee to contract owner
        payable(owner()).transfer(claimFee);

        // Mark the recipient as claimed
        _claimed[msg.sender] = true;

        // Emit event for claiming
        emit AirdropClaimed(msg.sender, airdropAmount);
    }

    function setTokenAddress(address tokenAddress) external onlyOwner {
        _token = IERC20(tokenAddress);
    }

    function withdrawEther(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Insufficient Ether balance");
        payable(owner()).transfer(amount);
        emit EtherWithdrawn(owner(), amount);
    }

    function withdrawToken(uint256 amount) external onlyOwner {
        require(amount <= _token.balanceOf(address(this)), "Insufficient Token balance");
        _token.transfer(owner(), amount);
        emit TokenWithdrawn(owner(), amount);
    }
}

