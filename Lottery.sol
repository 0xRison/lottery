//SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract Lottery {
    using SafeMath for uint256; 

    address payable[] public players;
    address public manager;

    modifier isManager{
        require(
            msg.sender == manager,
            "Only the manager can execute."
        );
        _;
    }

    constructor(){ manager = msg.sender; }

    receive() external payable {
        require(msg.value == 0.1 ether, "Must submit at least 0.1 ether");
        players.push(payable(msg.sender));
    }

    function getBalance() public view isManager returns(uint){
        return address(this).balance;
    }

    function pickWinner() public isManager{
        require(players.length >= 3, "Must have at least 3 participants");
        uint256 r = _random();
        address payable winner;
        uint index = r.mod(players.length);
        winner = players[index];
        winner.transfer(getBalance());
        players = new address payable[](0);
    }

    // replace with chainlink VRF if possible
    function _random() private view returns(uint){
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }
}
