pragma solidity 0.7.5;
pragma abicoder v2;

//– Anyone should be able to deposit ether into the smart contract

//The contract creator should be able to input (1): the addresses of the owners and (2):  
//the numbers of approvals required for a transfer, in the constructor. For example, 
//input 3 addresses and set the approval limit to 2. 

//– Anyone of the owners should be able to create a transfer request. 
//The creator of the transfer request will specify what amount and to what address the transfer will be made.

//Owners should be able to approve transfer requests.

//When a transfer request has the required approvals, the transfer should be sent. 

contract Deposit {
    
    
    constructor(){
     address owner = msg.sender;
    }
    
    //double mapping
    mapping(address => mapping(uint => uint))depositID;
    mapping(address => mapping(uint => bool))approvals;
    mapping(address => mapping(uint => uint))transactionID; //possible to triple map?
    mapping(address => mapping(uint => uint))transferSetupID;
    mapping(address => mapping(uint => uint))balance;
    mapping(address => mapping(uint => address))depositOwner;
    //mapping(address => uint) transactionID;
   
    address[] walletOwners;
    address payable[] clearToAdd;
    address payable[] adr;
    address payable[] toAdd;
    
    struct testPush{
         address payable[] depositUser;
         address payable[] approvedUsersForTransferRequest;
    } 
 
    struct depositRecord {
       uint txnId;
       address depositUser;
       uint numberOfOwners;
       uint numberOfApprovalsForTransfer;
       uint valueOfDeposit;
   }
   
   depositRecord[] InitialDeposit;
   
    struct transferSetting {
       uint txnId;
       address payable[] depositUser;
       bool withdrawStatus;
       
   }
   
   transferSetting[] transferSetup;
   
   
   
   struct transferRequest {
       uint txnId;
       address requestUser;
       uint valueOfTransfer;
       address addressToTransfer;
       uint numberOfOwners;
       uint numberOfApprovalsForTransfer;
   }
   
   transferRequest[] transferRequested;
   
   struct transferApproval {
       uint txnId;
       address approvingUser;
       bool approvalStatus;
   }
   
   transferApproval[] transferApproved;
  
    
    
    function depositEtherToContract(uint _txnId, uint _totalOwners, uint _approvalsForTransfer) public payable returns (string memory){
       require(_txnId > 0, "txnId must be a number above 0");
       uint mappedTxnId = _txnId;
       
       transactionID[msg.sender][_txnId] = mappedTxnId;
       depositOwner[msg.sender][_txnId] = msg.sender; 
       balance[msg.sender][_txnId] = msg.value;
       
       for (uint i = 0; i < InitialDeposit.length; i++) {
           require(InitialDeposit[i].txnId !=  transactionID[msg.sender][_txnId], "txnId duplicate, please key in an unused random deposit transaction ID");
       }
        InitialDeposit.push(depositRecord(transactionID[msg.sender][_txnId], msg.sender, _totalOwners, _approvalsForTransfer, msg.value));
        depositID[msg.sender][_txnId] = InitialDeposit.length;
        return "Deposit success, please key in deposit transaction ID in the future to check deposit";
    }
    
    //For deposit owner to track their deposit
    function findDeposit(uint _txnId) public view returns (depositRecord memory) {
        uint depositNumber = depositID[msg.sender][_txnId];
        return InitialDeposit[depositNumber - 1];
    }
        
    
    function assignSubOwners(uint _txnId, address payable _subOwner)public payable returns (string memory){
        uint depositNumber  = depositID[msg.sender][_txnId];
        if(InitialDeposit[depositNumber - 1].numberOfOwners > toAdd.length){
        toAdd.push(_subOwner);
        } 
        
        if (InitialDeposit[depositNumber - 1].numberOfOwners == toAdd.length) {
            transferSetup.push(transferSetting(depositNumber, toAdd, false));
            uint transferNumber = transferSetup.length;
            transferSetupID[msg.sender][_txnId] = transferNumber;
            toAdd = clearToAdd;
            return "All subOwners Filled";
        }
        return "it works";
    }
        
    function checkTransferSetting(uint _txnId)public view returns (transferSetting memory){
        uint transferNumber = transferSetupID[msg.sender][_txnId];
        return transferSetup[transferNumber - 1] ;
    }
    
    function requestForTransfer(uint _txnId, address _mainOwner, uint valueOfTransfer, address _transferTo) public returns (string memory){
        uint transferNumber = transferSetupID[_mainOwner][_txnId];
        bool scanStatus = false;
        for (uint i = 0; transferSetup[transferNumber - 1].depositUser.length >= i; i++){
            if (transferSetup[transferNumber - 1].depositUser[i] ==  msg.sender){
                scanStatus = true;
                return "You may continue, verified Owner/SubOwner" ;
                
            }
        }
        if (scanStatus == false){
            return "You are not verified for the transaction stated, please key in txn ID again";
        } 
        }
    
    function recordTransferRequest(uint _txnId, address _mainOwner, uint valueOfTransfer, address _transferTo)private {
        
    }
    
    
    
    
}
        
        
        