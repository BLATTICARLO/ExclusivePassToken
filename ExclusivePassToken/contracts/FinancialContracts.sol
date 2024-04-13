// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12 <0.9.0;


contract FinancialContracts {
  uint balance = 313000;

  address owner;

  constructor() {
    owner = msg.sender;
  }

  modifier ifOwner() {
    if(owner != msg.sender){
      revert();
    } else {
      _;
    }
  }

  function withdraw(uint funds) public ifOwner{
    payable(msg.sender).transfer(funds);
  }

  function receiveDeposit() payable public {

  }

  function getBalance() public view returns (uint) {
    return address(this).balance;
  }
  
  function depositUnit(uint newDeposit) public {
    balance = balance + newDeposit;
  }
}
