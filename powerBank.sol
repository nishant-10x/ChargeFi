// SPDX-License-Identifier: MIT

pragma solidity ^ 0.8.0;

contract PoweBank{

    address owner;

    constructor(){
        owner = msg.sender;
    }

    //register as renter
     struct Renter{
         address payable walletAddress;
         string firstName;
         string lastName;
         bool canRent;
         bool active;
         uint balance;
         uint due;
         uint start;
         uint end;
     }

     mapping (address => Renter) public renters;

     function addRenter(address payable walletAddress,string memory firstName,string memory lastName,bool canRent,bool active,uint balance,uint due,uint start,uint end) public{
         renters[walletAddress] = Renter(walletAddress, firstName, lastName, canRent, active, balance, due, start, end);
     }
    //checkout the powerbank

    function checkout(address walletAddress) public {
        require(renters[walletAddress].due == 0, "you have a pending balance.");
        require(renters[walletAddress].canRent == true, "you cannot rent at this time.");
        renters[walletAddress].active = true;
        renters[walletAddress].start = block.timestamp;
        renters[walletAddress].canRent = false;
    }

    //check in the powerbank
    function checkIn(address walletAddress) public {
        require(renters[walletAddress].active == true, "please return a powerBank first");
        renters[walletAddress].active = false;
        renters[walletAddress].end =block.timestamp ;
        //todo :set amount due 
        setDue(walletAddress);
    }

    //get the total duration of powerbank use
    function renterTimespan(uint start, uint end) internal pure returns(uint){
        return end - start;
    }
    function getTotalDuration(address walletAddress) public view returns(uint){
        if(renters[walletAddress].start == 0 || renters[walletAddress].end == 0 ){
            return 0;
        }
    else{
        uint timespan = renterTimespan(renters[walletAddress].start, renters[walletAddress].end);
        uint timespanInMinutes = timespan / 60;
        return timespanInMinutes;
    }
        

    }

    // get the contracts balance
    function balanceof() view public returns(uint){
        return address(this).balance;
    }
    
    // get the renter's balance
    function balanceOfRenter(address walletAddress) public view returns(uint){
        return renters[walletAddress].balance;
    }

    // set due amount
    function setDue(address walletAddress) internal{
    uint timespanMinutes = getTotalDuration(walletAddress);
    uint thirtyMinutes = timespanMinutes / 30;
    renters[walletAddress].due = thirtyMinutes * 2 ;


}

function canRentPowerbnk(address walletAddress) public view returns(bool){
    return renters[walletAddress].canRent;
}
//deposit
function deposit (address walletAddress) payable public {
    renters[walletAddress].balance +=msg.value;

}

//make payment
function makePayment(address walletAddress)payable public {
    require(renters[walletAddress].due >= 0, "you dont have to pay now");
    require(renters[walletAddress].balance >= msg.value, "you dont have enough funds to pay deposit now.");
    renters[walletAddress].balance -= msg.value;
    renters[walletAddress].canRent = true;
    renters[walletAddress].due = 0;
    renters[walletAddress].start = 0;
    renters[walletAddress].end = 0;

}
 function getDue(address walletAddress)public view returns(uint){
     return renters[walletAddress].due;
 } 
 function getRenter(address walletAddress) public view returns(string memory firstName, string memory lastName, bool canRent,bool active){
     firstName = renters[walletAddress].firstName;
     lastName = renters[walletAddress].lastName;
     canRent = renters[walletAddress].canRent;
     active = renters[walletAddress].active;
 }
  function renterExists(address walletAddress) public view returns(bool){
     if(renters[walletAddress].walletAddress != address(0)){
         return true;
     }
      return false;
   }
 
}