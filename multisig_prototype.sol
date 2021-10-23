pragma solidity 0.7.5;
pragma abicoder v2;
contract MultiSigWallet{
    
   
    //mapping
    mapping(address => mapping(uint => uint))depositID;
    mapping(address => mapping(uint => uint))transferSetupID;
    mapping(address => mapping(uint => uint))balance;
    mapping(address => mapping(uint => address))depositOwner;
    
    //state variables?
    address[] walletOwners;
    address payable[] clearToAdd;
    address payable[] adr;
    address[] toAdd;
    address[] toClear;
    address blankAddress;
    bool[] toFalse;
    string fillerString = "Just filling a return";
    uint fillerInt = 0;
    
    
    //structs
    struct testPush {
         address payable[] depositUser;
         address payable[] approvedUsersForTransferRequest;
    } 
 
    //struct to keep deposit records
    struct depositRecord {
       uint txnId;
       address depositOwner;
       uint numberOfOwners;
       uint numberOfApprovalsForTransfer;
       uint valueOfDeposit;
   }
   
   depositRecord[] InitialDeposit;
   
    //struct for setting transfer permission   
    struct transferPermission {
       uint depositId;
       address[] depositUser;
       bool[] withdrawStatus;
       uint transferRequestID;
       bool settingComplete;
   }
   
   transferPermission[] transferPermissionSetting;
   
   //struct for storing transfer information
   struct transferInfo {
       uint depositID;
       uint transferRequestID;
       uint transferValue;
       bool finalApproval;
   }
   
    //function to deposit Ether into this contract
    function depositEtherToContract(uint _totalOwners, uint _approvalsForTransfer) public payable returns (string memory, uint){
        require(msg.value > 0, "There is no Ether being deposited");
        assert(msg.value > 0);
        
        uint depositIndex = InitialDeposit.length;
        InitialDeposit.push(depositRecord(depositID[msg.sender][depositIndex + 1], msg.sender, _totalOwners, _approvalsForTransfer, msg.value));

        uint depositTxnID = InitialDeposit.length;
        depositOwner[msg.sender][depositTxnID] = msg.sender; 
        balance[msg.sender][depositTxnID] = msg.value;
        depositID[msg.sender][depositTxnID] = depositTxnID;
        
        return ("Deposit success, please key in deposit transaction ID in the future to check deposit. Your Txn ID is", depositTxnID);
    }
    
    //function to check the deposit using the Txn ID
    function findDeposit(uint _txnId) public view returns (depositRecord memory) {
        uint depositNumber = depositID[msg.sender][_txnId];
        require (depositNumber != 0, "You've key in an invalid number aka wrong transaction ID, 0 etc");
        return InitialDeposit[depositNumber - 1];
    }
    
    
    //function to assign owner and subowner for specific deposit
    function assignSubOwners(uint _txnId, address _subOwner)public returns (string memory, uint){
        
        
        uint depositNumber  = depositID[msg.sender][_txnId];
        uint depositIndexAssign = depositNumber - 1; //index starts at zero but content with length starts at 1
        uint noShareOwners = InitialDeposit[depositIndexAssign].numberOfOwners;
       
        require (msg.sender == InitialDeposit[depositIndexAssign].depositOwner);
        
        if (noShareOwners > toAdd.length){
        toAdd.push(_subOwner);
        toFalse.push(false);
        
        } 
        
        if (noShareOwners == toAdd.length) {
            uint transferRequestID = transferPermissionSetting.length;
            transferPermissionSetting.push(transferPermission(depositNumber, toAdd, toFalse, transferRequestID, true));
            
            uint transferNumber = transferPermissionSetting.length;
            transferSetupID[msg.sender][_txnId] = transferNumber;
            delete toAdd;
            delete toFalse;
            return ("A address has been added to approve withdrawals, All subOwners Filled. Your transfer Request ID is", transferRequestID) ;
        }
        
        return ("A address has been added to approve withdrawals", fillerInt);
        
    }
    
    //function to check status of withdrawal permission of specific depositNumber
        function checkPermissionSetting(uint _txnId)public view returns (transferPermission memory){
        uint transferNumber = transferSetupID[msg.sender][_txnId];
        uint transferIndex = transferNumber - 1 ;
        return transferPermissionSetting[transferIndex];
    }
    
    //function to request for withdrawal from any of the owner/subOwners
        function requestForTransfer(uint _txnId, address _mainOwner, uint _transferValue) public returns (string memory){
       
        uint transferNumber = transferSetupID[_mainOwner][_txnId];
        bool scanStatus = false;
        
        
        for (uint i = 0; transferPermissionSetting[transferNumber - 1].depositUser.length >= i; i++){
            if (transferPermissionSetting[transferNumber - 1].depositUser[i] ==  msg.sender){
                scanStatus = true;
                transferPermissionSetting[transferNumber - 1].withdrawStatus[i] = true;
                return "You may continue, verified Owner/SubOwner" ;
            }
        }
        
        if (scanStatus == false){
            return "You are not verified for the transaction stated, please key in txn ID again";
        } 
        
        return "Cheers?";
    }
    
        function approveRequestForTransfer(uint _DepositID, uint _TransferID) public returns (string memory) {
            
            
            
        }
        
        function checkStatus(uint _index) public returns (address){
            return toAdd[_index];
        } 
    
}