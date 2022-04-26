// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract coin_flip {
    event Log(address indexed sender, uint message);
    address public user;
    mapping (address => uint) public money;
    

    constructor() {
        user = msg.sender;
        money[address(this)] = 100;
    }

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

    function addMoneyAfterwin (uint betMoney) public{
        require(msg.sender == user, "Not the correct user.");
        money[address(user)] += 2*betMoney;
    }

    function compareBidMoneyWithUserMoney(uint betMoney) public view returns (bool) {
        if(money[address(user)] >= betMoney) return true;
        return false; 
    }
    function makeBet(uint betMoney) public {
        uint coinFlippedValue = vrf() % 2;
        if(coinFlippedValue == 1){
            addMoneyAfterwin(betMoney);
            emit Log(msg.sender, betMoney);
        }
    }
    function main() public {
        while(money[address(user)] > 0){
            uint guessedBetValue = vrf() % 100;
            if(compareBidMoneyWithUserMoney(guessedBetValue)){
                money[address(user)] -= guessedBetValue;
                makeBet(guessedBetValue);
            }
        }
    }
    
}