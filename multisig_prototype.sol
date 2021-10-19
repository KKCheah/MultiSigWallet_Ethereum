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
     
    }
    
    //double mapping
    mapping(address => mapping(uint => mapping(uint => bool)))depositID;
    mapping(address => mapping(uint => bool))approvals;
    mapping(address => mapping(uint => uint))transactionID; //possible to triple map?
    mapping(address => mapping(uint => uint))balance;
    //mapping(address => uint) transactionID;
   
    address[] walletOwners;
    
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
       address depositUser;
       address approvedUsersForTransferRequest;
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
       balance[msg.sender][_txnId] = msg.value;
       
       for (uint i = 0; i < InitialDeposit.length; i++) {
           require(InitialDeposit[i].txnId !=  transactionID[msg.sender][_txnId], "txnId duplicate, please key in an unused random deposit transaction ID");
       }
        InitialDeposit.push(depositRecord(transactionID[msg.sender][_txnId], msg.sender, _totalOwners, _approvalsForTransfer, msg.value));
        return "Deposit success, please key in deposit transaction ID in the future to check deposit";
    }
    
    function findDeposit(uint _txnId) public view returns (depositRecord memory display) {
        for (uint i = 0; i < InitialDeposit.length; i++) {
                if (InitialDeposit[i].txnId == _txnId) {
                    return InitialDeposit[i];
                } 
                    
                }

            }
        
    
    
    function assignTotalOwner()public{
        
    }
    
    function testFunction(uint _button, uint _txnId) public view returns(uint, uint) {
        uint buttonTest = _button;
        return (buttonTest, balance[msg.sender][_txnId]);
    }
    
    
    
   
    struct documentHolder {
        uint Number;
        string fileName;
        bool approvalStatus;
    }
    
    
    
    documentHolder[] myDocument;
    
    
    function addDocument(uint _number, string memory _fileName) public {
        myDocument.push(documentHolder(_number,_fileName, false));
    }
    
    function retrieveDocument(uint _index) view public returns(documentHolder memory){
        return myDocument[_index];
    }
    function checkApproval(uint _transferid) public view returns (bool){
        bool approvalStatus = approvals[msg.sender][_transferid];
        return approvalStatus;
    }
    
}