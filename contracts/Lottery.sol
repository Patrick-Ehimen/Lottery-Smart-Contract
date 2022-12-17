// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract lottery {
    //declare the state variables
    address payable[] public players;
    address public manager;
    mapping(address => bool) public received;

    //declared the constructor
    constructor() {
        manager = msg.sender;
    }

    receive() external payable {
        require(msg.sender != manager);
        require(msg.value == 0.1 ether);

        // appending the player to the players array
        players.push(payable(msg.sender));
        require(!received[msg.sender], "You can only send once");
        received[msg.sender] = true;
    }

    function getBalamce() public view returns (uint) {
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
}
