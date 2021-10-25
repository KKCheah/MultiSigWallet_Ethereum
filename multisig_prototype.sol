pragma solidity 0.7.5;
pragma abicoder v2;
contract MultiSigWallet{
    
   
    //mapping
    mapping(address => mapping(uint => uint))depositID;
    mapping(address => mapping(uint => uint))balance;
    mapping(address => mapping(uint => address))depositOwner;
    mapping(address => mapping(uint => mapping(uint => uint)))WithdrawSettingID;
    mapping(address => mapping(uint => mapping(uint => uint)))TransferRequestID;
    
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
       address[] depositUsers;
       bool[] withdrawStatus;
       uint WithdrawSettingID;
       bool settingComplete;
   }
   
   transferPermission[] transferPermissionSetting;
   
   //struct for storing transfer information
   struct withdrawalInfo {
       uint depositID;
       uint WithdrawSettingID;
       uint transferValue;
       address toTransfer;
       bool finalApproval;
   }
   
   withdrawalInfo[] withdrawalInformation;
   
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
            uint transferSetupID = transferPermissionSetting.length;
            transferPermissionSetting.push(transferPermission(depositNumber, toAdd, toFalse, transferSetupID, true));
            uint transferNumber = transferPermissionSetting.length;
            WithdrawSettingID[msg.sender][_txnId][transferSetupID] = transferNumber;
            delete toAdd;
            delete toFalse;
            return ("A address has been added to approve withdrawals, All subOwners Filled. Your transfer Request ID is", transferSetupID) ;
        }
        
        return ("A address has been added to approve withdrawals", fillerInt);
        
    }
    
    //function to check status of withdrawal permission of specific depositNumber
        function checkPermissionSetting(uint _txnId, uint _transferSetupID)public view returns (transferPermission memory){
        uint transferNumber = WithdrawSettingID[msg.sender][_txnId][_transferSetupID];
        uint transferIndex = transferNumber - 1 ;
        return transferPermissionSetting[transferIndex];
    }
    
    //function to request for withdrawal from any of the owner/subOwners
        function requestForTransfer(uint _depositID, uint _transferSetupID, address _mainOwner, uint _transferValue, address _recipient) public returns (string memory){
       
        uint requestNumber = WithdrawSettingID[msg.sender][_depositID][_transferSetupID];
        bool scanStatus = false;
        

        for (uint i = 0; transferPermissionSetting[requestNumber - 1].depositUsers.length >= i; i++){
            if (transferPermissionSetting[requestNumber - 1].depositUsers[i] ==  msg.sender){
                scanStatus = true;
                transferPermissionSetting[requestNumber - 1].withdrawStatus[i] = true;
                withdrawalInformation.push(withdrawalInfo(_depositID,requestNumber, _transferValue, _recipient, false));
                return "You may continue, verified Owner/SubOwner" ;
            }
        }
        
        if (scanStatus == false){
            return "You are not verified for the transaction stated, please key in deposit and transfer setting ID again";
        } 
        
        return "You're not supposed to reach here";
    }
    
        function approveRequestForTransfer(uint _DepositID, uint _TransferID) public returns (string memory) {
            
            
            
        }
        
        function checkStatus(uint _index) public returns (address){
            return toAdd[_index];
        } 
    
}