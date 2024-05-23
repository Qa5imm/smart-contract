// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

contract BankingSystem {
    // DECLARATIONS
    address public owner;
    // CODE
    // Constructor
    constructor() {
        owner = tx.origin;
    }

    struct details
    {
        string first_name;
        string last_name;
        uint loan_amount;
        uint balance;
    }
    mapping (address=> details) public userdetails;

    address [] useraddress;
    
    uint bankreserves=0;


    function openAccount(string memory firstName, string memory lastName) public {
            
            if (tx.origin== owner)
            {
               revert("Error, Owner Prohibited");
            }
            if (!checkaddress(tx.origin))
            {
                revert("Account already exists");
            }
            else
            {
                userdetails[tx.origin].first_name = firstName;
                userdetails[tx.origin].last_name = lastName;
                userdetails[tx.origin].balance = 0;
                userdetails[tx.origin].loan_amount = 0;
                useraddress.push(tx.origin);
            }

    }
    function checkaddress(address addofuser) view public returns (bool)
    {
        for (uint i=0; i < useraddress.length ; i++)
        {
            if (addofuser == useraddress[i])
            {
                return false;
            }
        }
        return true;
    }

    function getDetails() public view returns (uint balance, string memory first_name, string memory last_name, uint loanAmount) {
        if (checkaddress(tx.origin))
        {
            revert("No Account");
        }
        return (userdetails[tx.origin].balance,userdetails[tx.origin].first_name,userdetails[tx.origin].last_name,userdetails[tx.origin].loan_amount  );
    }


    // minimum deposit of 1 ether.
    // 1 ether = 10^18 Wei.   
    function depositAmount() public payable { 
        if (tx.origin== owner)
        {
            revert("Error, Owner Prohibited");
        }
        if (checkaddress(tx.origin))
        {
            revert("No Account");
        }
        if (msg.value < 1000000000000000000)
        {
            revert("Low Deposit");                              
        }
        else
        {
            uint deposit= msg.value;
            userdetails[tx.origin].balance= userdetails[tx.origin].balance+deposit;
        }
    }    
    function withDraw(uint withdrawalAmount) public { 
        if (tx.origin== owner)
        {
            revert("Error, Owner Prohibited");
        }
        if (checkaddress(tx.origin))
        {
            revert("No Account");
        }
        if(withdrawalAmount > userdetails[tx.origin].balance)
        {
            revert("Insufficient Funds");                  
        }
        else
        {
            userdetails[tx.origin].balance= userdetails[tx.origin].balance - withdrawalAmount;
            payable(tx.origin).transfer(withdrawalAmount); 
        }
    }
    function TransferEth(address payable reciepent, uint transferAmount) public {            /// what we hvae to do in this function?
        if (tx.origin== owner)
        {
            revert("Error, Owner Prohibited");
        }
        if (checkaddress(tx.origin))
        {
            revert("No Account");
        }
        if(transferAmount > userdetails[tx.origin].balance)
        {
            revert("Insufficient Funds");
        }
        else
        {
            userdetails[tx.origin].balance = userdetails[tx.origin].balance - transferAmount;
            userdetails[reciepent].balance= userdetails[reciepent].balance + transferAmount;
        }

    }
    function depositTopUp() public payable {
        if(tx.origin!=owner)
        { 
            revert("Only owner can call this function");
        }
        else
        {
            bankreserves= msg.value;
        }
    }

    function TakeLoan(uint loanAmount) public {

        if (tx.origin== owner)
        {
            revert("Error,Owner Prohibited");
        }
        if (checkaddress(tx.origin))
        {
            revert("No Account");
        }
        if(loanAmount > bankreserves)
        {
            revert("Insufficent Loan Funds");
        }
        if(loanAmount > (2*userdetails[tx.origin].balance))
        {
            revert("Loan Limit Exceeded");
        }

        userdetails[tx.origin].loan_amount= userdetails[tx.origin].loan_amount + loanAmount;
        payable(tx.origin).transfer(loanAmount);
        bankreserves= bankreserves- loanAmount;
    }
        

    function InquireLoan() public view returns (uint loanValue) {
        if (tx.origin==owner)
        {
               revert("Error,Owner Prohibited");
        }
        if (checkaddress(tx.origin))
        {
            revert("No Account");
        }
        else
        {
            return userdetails[tx.origin].loan_amount;
        }
    }
    function deployeradd() public view returns (address)
    {
        return owner;
    }

    function returnLoan() public payable  {
        if (tx.origin== owner)
        {
            revert("Error,Owner Prohibited");
        }
        if (checkaddress(tx.origin))
        {
            revert("No Account");
        }
        if(userdetails[tx.origin].loan_amount==0)
        {
            revert("No Loan");
        }
        if (msg.value >userdetails[tx.origin].loan_amount)
        {
            revert("Owed Amount Exceeded");
        }
        else
        userdetails[tx.origin].loan_amount=userdetails[tx.origin].loan_amount- msg.value;
    }


    function AmountInBank() public view returns(uint) {
            // DONT ALTER THIS FUNCTION
            return address(this).balance;
    }
     

    
}   

