//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract CrowdFunding {
    // A fund me `aid` contract:
    // where a person can intiate a fund me , specify address, target amount
    // other people can then come and contribute , and once the targetAmount has been reached the goFund ends and funds are transferred to the initiator account
    // scenario: Alice needs helps with her business , she can come to the smart contract, initiate a gofund me and set a timer 
    // Bob and alice can contribute to her course and once her target has been reached the contract locks and the funds are transferred to the intitiator account(alice)

    address payable initiator;
    struct Fund {
    // address payable initiator;
    uint256 target;
    uint256 timer;
    mapping(address => uint) balance; 
    bool isActive;
    }

    constructor(){
        initiator = payable(msg.sender);
    }

    modifier onlyInitiator(){
        require(initiator == msg.sender ,"Only initiator can withdraw");
        _;
    }


    mapping(uint256 => Fund) public funds;
    uint256 indexToFund = 0;

    function initiateHelp(uint _target, uint timer) external {
        Fund storage f = funds[indexToFund];
        f.target = _target;
        f.timer = block.timestamp+timer;
        f.isActive = true;
        indexToFund +=1;
    }

// contribute should enable addresses add money to the initiator account i.e balance should increase

function contribute(uint _index) payable public {
Fund storage f = funds[_index];
// check that target is less than balance if 1 proceed to contribution , else target === balance
require(f.balance[initiator] != f.target, "Target Reached!");
require(block.timestamp <= f.timer);
f.balance[initiator]+= msg.value;
}

function getBalance(uint index) external view returns (uint){
    Fund storage f = funds[index];
  return  f.balance[initiator];
}

// require that only initiatot can withdraw
function withdraw(uint _index, address payable eoa) onlyInitiator payable external{
    Fund storage f = funds[_index];
require( f.target == f.balance[initiator],"target is yet to be reached");
require(block.timestamp > f.timer, "mature time never reach");
eoa.transfer(f.balance[initiator]);
f.balance[initiator] = 0;
}

}
