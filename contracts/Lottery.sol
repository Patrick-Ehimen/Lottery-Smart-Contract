// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract LotteryContract {
    //declare the state variables
    address payable[] public players;
    address public manager;
    mapping(address => bool) public received;

    //declared the constructor
    constructor() {
        manager = msg.sender;
    }

    //function to recieve ether
    receive() external payable {
        //the manager is not permited to send ether
        require(msg.sender != manager);
        require(msg.value == 0.1 ether);

        // appending the player to the players array
        players.push(payable(msg.sender));
        require(!received[msg.sender], "You can only send once");
        received[msg.sender] = true;
    }

    function getBalance() public view returns (uint) {
        require(msg.sender == manager);
        //returns balance in wei
        return address(this).balance;
    }

    //function that returns a big random integer
    function random() internal view returns (uint) {
        return
            uint(
                keccak256(
                    abi.encodePacked(
                        block.difficulty,
                        block.timestamp,
                        players.length
                    )
                )
            );
    }

    function pickWinner() public {
        // only the manager can pick a winner if there are at least 3 players in the lottery
        require(msg.sender == manager);
        require(players.length >= 3);

        uint r = random();
        address payable winner;

        // computing a random index of the array
        uint index = r % players.length;

        winner = players[index]; // this is the winner

        uint managerFee = (getBalance() * 10) / 100; // manager fee is 10%
        uint winnerPrize = (getBalance() * 90) / 100; // winner prize is 90%

        // transferring 90% of contract's balance to the winner
        winner.transfer(winnerPrize);

        // transferring 10% of contract's balance to the manager
        payable(manager).transfer(managerFee);

        // resetting the lottery for the next round
        players = new address payable[](0);
    }
}
