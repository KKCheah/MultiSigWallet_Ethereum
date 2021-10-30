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
    bool[] toFalse;
    uint fillerInt = 0;
    
    
    //structs

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
       uint minNoOfApproval;
       uint WithdrawSettingID;
       bool settingComplete;
   }
   
   transferPermission[] transferPermissionSetting;
   
   //struct for storing transfer information
   struct withdrawalInfo {
       address userRequesting;
       uint depositID;
       uint WithdrawSettingID;
       uint TransferingNo;
       uint transferValue;
       address toTransfer;
       bool finalApproval;
   }
   
   withdrawalInfo[] withdrawalInformation;
   
   
   //event
   event SuccessfulTransfer(uint indexed value, address indexed recipient, uint indexed tranferRequestNo);
   
    //function to deposit Ether into this contract
    function depositEtherToContract(uint _totalOwners, uint _approvalsForTransfer) public payable returns (string memory, uint){
        require(msg.value > 0, "There is no Ether being deposited");
        assert(msg.value > 0);
        
        uint depositIndex = InitialDeposit.length;
        uint depositTxnID = InitialDeposit.length;
        InitialDeposit.push(depositRecord(depositID[msg.sender][depositIndex], msg.sender, _totalOwners, _approvalsForTransfer, msg.value));

        
        depositOwner[msg.sender][depositTxnID] = msg.sender; 
        balance[msg.sender][depositTxnID] = msg.value;
        depositID[msg.sender][depositTxnID] = depositTxnID;
        
        return ("Deposit success, please key in deposit transaction ID in the future to check deposit. Your Txn ID is", depositTxnID);
    }
    
    //function to check the deposit using the Txn ID
    function findDeposit(uint _txnId) public view returns (depositRecord memory) {
        uint depositNumber = depositID[msg.sender][_txnId];
        require (depositNumber >= 0, "You've key in an invalid number aka wrong transaction ID etc");
        return InitialDeposit[depositNumber];
    }
    
    
    //function to assign owner and subowner for specific deposit
    function assignSubOwners(uint _txnId, address _subOwner)public returns (string memory, uint){
        
        
        uint depositNumber  = depositID[msg.sender][_txnId];
        uint depositIndexAssign = depositNumber; //index starts at zero but content with length starts at 1
        uint noShareOwners = InitialDeposit[depositIndexAssign].numberOfOwners;
        uint _minNoOfApproval = InitialDeposit[depositIndexAssign].numberOfApprovalsForTransfer;
        require (msg.sender == InitialDeposit[depositIndexAssign].depositOwner);
        
        if (noShareOwners > toAdd.length){
        toAdd.push(_subOwner);
        toFalse.push(false);
        
        } 
        
        if (noShareOwners == toAdd.length) {
            uint transferSetupID = transferPermissionSetting.length;
            uint transferNumber = transferPermissionSetting.length;
            transferPermissionSetting.push(transferPermission(depositNumber, toAdd, toFalse, _minNoOfApproval, transferSetupID, true));
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
        uint transferIndex = transferNumber;
        return transferPermissionSetting[transferIndex];
    }
    
    //function to request for withdrawal from any of the owner/subOwners
        function requestForTransfer(uint _depositID, uint _transferSetupID, address _mainOwner, uint _transferValue, address _recipient) public returns (string memory, uint){
        
        uint transferNumber = withdrawalInformation.length;
        uint requestNumber = WithdrawSettingID[_mainOwner][_depositID][_transferSetupID];
        bool scanStatus = false;
        uint requestIndex = requestNumber;
        
        
        for (uint i = 0; transferPermissionSetting[requestNumber].depositUsers.length >= i; i++){
            if (transferPermissionSetting[requestNumber].depositUsers[i] ==  msg.sender){
                scanStatus = true;
                transferPermissionSetting[requestNumber].withdrawStatus[i] = true;
                TransferRequestID[msg.sender][requestNumber][withdrawalInformation.length] = transferNumber;
                
                require(InitialDeposit[_depositID].valueOfDeposit >= _transferValue, "Insufficient funds to perform transfer");
                
                withdrawalInformation.push(withdrawalInfo(msg.sender, _depositID, requestIndex, transferNumber, _transferValue, _recipient, false));
                
                assert(InitialDeposit[_depositID].valueOfDeposit >= _transferValue);
                
                return ("Request accepted and pending, you transfer number is", transferNumber) ;
            }
        }
        
        if (scanStatus == false){
            return ("You are not verified for the transaction stated, please key in deposit and transfer setting ID again, error code", 1);
        } 
        
        return ("You're not supposed to reach here, error code:", 2);
    }
    
        function check(uint _transferNo) public view returns(withdrawalInfo memory){
            return withdrawalInformation[_transferNo];
        }
        
        
        function approveRequestForTransfer(address _requestUser, uint _transferNo) public returns (address, string memory) {
            if (withdrawalInformation[_transferNo].userRequesting == _requestUser){
                bool scanStatus = false;
                uint countApproval = 0;
                uint value = withdrawalInformation[_transferNo].WithdrawSettingID;
                uint arrayLength = transferPermissionSetting[value].depositUsers.length;
                for (uint z = 0; arrayLength >= z; z++){
                    if (transferPermissionSetting[value].depositUsers[z] ==  msg.sender){ 
                        scanStatus = true;
                        transferPermissionSetting[value].withdrawStatus[z] = true;
                        for (uint y = 0; transferPermissionSetting[value].withdrawStatus.length >= y; y++){
                            if (transferPermissionSetting[value].withdrawStatus[y] = true) {
                                countApproval++;
                                if(countApproval>=transferPermissionSetting[value].minNoOfApproval){
                                require (transferPermissionSetting[value].depositId == InitialDeposit[value].txnId, "Error at the comparison");
                                balanceTranfer(_transferNo, withdrawalInformation[_transferNo].transferValue);
                                resetWithdrawStatus(_transferNo);
                                return (msg.sender, "Congratulation");
                                }
                            }
                        }
                        return (msg.sender, "Approved");
                    }
                }
                return (msg.sender, "Failed 1");
            }
        return (msg.sender, "Failed 2");
        }
        
        function balanceTranfer(uint _transferNo, uint _valueOfTransfer ) private returns (string memory, address, string memory, uint){
            withdrawalInformation[_transferNo].finalApproval = true;
            payable(withdrawalInformation[_transferNo].toTransfer).transfer(_valueOfTransfer);
            InitialDeposit[withdrawalInformation[_transferNo].depositID].valueOfDeposit  -= _valueOfTransfer;
            emit SuccessfulTransfer(_valueOfTransfer, withdrawalInformation[_transferNo].toTransfer, _transferNo);
            return ("transferred to address: ", withdrawalInformation[_transferNo].toTransfer, " with a value of: ", _valueOfTransfer);
        }
        
        function resetWithdrawStatus(uint _transferNo) private {
            for (uint i = 0; transferPermissionSetting[withdrawalInformation[_transferNo].WithdrawSettingID].withdrawStatus.length <= i; i++){
                transferPermissionSetting[withdrawalInformation[_transferNo].WithdrawSettingID].withdrawStatus[i] = false;
            }
        }
}