// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

// contract to deal with coin flip
contract coin_flip {
    event Log(address indexed sender, uint message);
    address public user;
    mapping (address => uint) public money;
    

    constructor() {
        user = msg.sender;
        money[address(this)] = 100;
    }
    // VRF function returning random number
    function vrf() public view returns (uint result) {
        uint[1] memory bn;
        bn[0] = block.number;
        assembly {
          let memPtr := mload(0x40)
          if iszero(staticcall(not(0), 0xff, bn, 0x20, memPtr, 0x20)) {
            invalid()
          }
          result := mload(memPtr)
        }
    }

    // If user's wins, add the betMoney into his account
    function addMoneyAfterwin (uint betMoney) public{
        // checking the correct user
        require(msg.sender == user, "Not the correct user.");
        money[address(user)] += 2*betMoney;         // 2 times the value of betMoney added
    }

    // boolean function to find whether bid value is less than the user's account money.
    function compareBidMoneyWithUserMoney(uint betMoney) public view returns (bool) {
        // checking the correct user
        require(msg.sender == user, "Not the correct user.");
        if(money[address(user)] >= betMoney) return true;       // betMoney is valid if it is less than user's account money
        return false; 
    }

    // if coinFlippedValue matches, the user wins the bet
    function makeBet(uint betMoney, uint choice) public {
        uint coinFlippedValue = vrf() % 2;

        // if the flipped coin value matches with the user's choice
        if(coinFlippedValue == choice){
            // bet money has to be added to user's accunt after winning.
            addMoneyAfterwin(betMoney);
            emit Log(msg.sender, betMoney);
        }
    }

    function main() public {
        if(compareBidMoneyWithUserMoney(msg.guessedBetValue)){
            money[address(user)] -= msg.guessedBetValue;
            makeBet(msg.guessedBetValue, msg.choice);
        }
    }
    
}