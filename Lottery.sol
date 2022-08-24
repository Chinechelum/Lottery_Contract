// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

contract Lottery {
    uint public currentLotteryId;

    struct aLottery{
        uint lotteryId;
        address owner;
        uint amountToEnter;
        uint endTime;
        uint totalBalance;
        address payable[] players;
        address winner;
    }
    
    mapping (uint => aLottery) allLotteries;

    event lotteryCreated(string, uint, string, uint);
    event showWinner(string, address);

    event myMaker(address, string);
    constructor() {
        address maker = msg.sender;
        emit myMaker(maker, " is my maker.");
    }

    function createLottery(uint _amount, uint _endTime) public {
        require(_amount > 0, "Amount to enter must be greater than zero");
        require(_endTime > block.timestamp, "Amount to enter must be greater than zero");
        aLottery storage newLottery = allLotteries[++currentLotteryId];
        newLottery.lotteryId = currentLotteryId;
        newLottery.owner = msg.sender;
        newLottery.amountToEnter = _amount;
        newLottery.endTime = _endTime;
        emit lotteryCreated("Lottery created with ID: ", newLottery.lotteryId, " and amount to enter: ", newLottery.amountToEnter);
    }

    function enterLottery(uint _lotteryId) public payable {
        aLottery storage theLottery = allLotteries[_lotteryId];
        require(block.timestamp < theLottery.endTime, "Can no longer enter this lottery.");
        require(msg.value == theLottery.amountToEnter, "Not the amount to enter this lottery.");
        theLottery.totalBalance += msg.value;
        // the address of the person entering the lottery
        theLottery.players.push(payable(msg.sender));
    }   

    function spinTheWheel(uint _lotteryId) public returns (address winner){
        aLottery storage theLottery = allLotteries[_lotteryId];
        require(block.timestamp > theLottery.endTime, "Not yet time to end this lottery, calma.");
        uint index = getRandomNumber(_lotteryId) % theLottery.players.length;
        if (theLottery.winner == address(0)){
            theLottery.winner = theLottery.players[index];
            payable(theLottery.winner).transfer(address(this).balance);
            emit showWinner("The winner is: ", theLottery.winner);
            return theLottery.winner;
        }else {
            address dummyWinner = theLottery.players[index];
            emit showWinner("The dummy winner is: ", dummyWinner);
            return dummyWinner;

            
        }
    }

     function getRandomNumber(uint _lotteryId) public view returns (uint) {
        aLottery storage theLottery = allLotteries[_lotteryId];
        return uint(keccak256(abi.encodePacked(theLottery.owner, block.timestamp)));
    }
    
    function getBalanceOfLottery(uint _lotteryId) public view returns (uint) {
        aLottery storage theLottery = allLotteries[_lotteryId];
        return theLottery.totalBalance;
    }
    
    function getEndTime(uint _lotteryId) public view returns (uint) {
        aLottery storage theLottery = allLotteries[_lotteryId];
        return theLottery.endTime;
    }
    
    function getWinnerOfLottery(uint _lotteryId) public view returns (address) {
        aLottery storage theLottery = allLotteries[_lotteryId];
        return theLottery.winner;
    }

    function getPlayersOfLottery(uint _lotteryId) public view returns (address payable[] memory) {
        aLottery storage theLottery = allLotteries[_lotteryId];
        return theLottery.players;
    }
    
            

}
