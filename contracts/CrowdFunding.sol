//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

// V1
// V2 would implement a multisig.
contract CrowdFunding {

        // A fundme `aid` contract:
    // where a person can intiate a fund me , specify address, target amount,  time.
    // other people can then come and contribute , and once the targetAmount has been reached the goFund ends and funds are transferred to the initiator account
    // scenario: Alice needs helps with her business , she can come to the smart contract, initiate a gofund me and set a timer 
    // Bob and any other person can contribute to her course and once her target has been reached the contract locks and the funds are transferred to the intitiator account(alice)
    struct Fund {
        address initiator;
        uint256 target;
        uint256 timer;
        mapping(address => uint) contribution; 
        uint contributedAmt;
        bool isActive;
    }
 


    mapping(uint256 => Fund) public funds;
    uint256 indexToFund = 0;

    function initiateHelp(uint _target, uint timer)  external {
        Fund storage f = funds[indexToFund];
        f.initiator = msg.sender;
        f.target = _target;
        f.timer = block.timestamp + timer;
        f.isActive = true;
        indexToFund +=1;
    }

    // contribute should enable addresses add money to the initiator account i.e balance should increase

    function contribute(uint _index) payable public {
        Fund storage f = funds[_index];
        require( f.isActive, "Target reached or Inactive");

        // check that target is less than balance if 1 proceed to contribution , else target === balance
        require(f.contributedAmt + msg.value <= f.target, "Target would be exceeded!");
        require(block.timestamp <= f.timer);
        if (block.timestamp >= f.timer){
            f.isActive = false;
        }
        f.contribution[msg.sender] += msg.value;
        f.contributedAmt += msg.value;
        
    }

    function getBalance(uint index) external view returns (uint){
        Fund storage f = funds[index];
        return  f.contributedAmt;
    }

    // require that only initiatot can withdraw
    function withdraw(uint _index)  payable external{
        Fund storage f = funds[_index];
        require(block.timestamp >= f.timer, "mature time never reach");
        require(f.initiator == msg.sender, "Only initiator can withdraw");
        payable(f.initiator).transfer(f.contributedAmt);
        f.contributedAmt = 0;
    }


}
