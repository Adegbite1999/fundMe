//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";

// V1
// V2 would implement a multisig.
contract CrowdFunding {
    address payable initiator;
    struct Fund {
        uint256 target;
        uint256 timer;
        mapping(address => uint) contribution; 
        uint contributedAmt;
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
    function withdraw(uint _index, address payable eoa) onlyInitiator payable external{
        Fund storage f = funds[_index];
        require(block.timestamp >= f.timer, "mature time never reach");
        eoa.transfer(f.contributedAmt);
        f.contributedAmt = 0;
        // f.isActive = false;
    }


}
