pragma solidity ^0.4.11;
contract IssuingBank {
    
    
    string constant NoneString = ""; 
    bytes32 constant NoneBytes32 = bytes32(0);
    int64 constant NoneInt64 = int64(0);
    uint256 constant NoneUint256 = uint256(0);
    address constant NoneAddress = address(0x00);
    
    address public owner;
    string public bankName;
    string public bankInformationLink;
    bytes32 public bankDataHash;
    
    enum SubcontractType { Deposit, Undefined }

    uint256 private depositsCounter = 0;
    
    mapping(uint256 => address) deposits;
    
    
    function IssuingBank(string _name, string _additionalInfoLink, bytes32 _dataHash){
        owner = msg.sender;
        bankName = _name;
        bankInformationLink = _additionalInfoLink;
        bankDataHash = _dataHash;
        depositsCounter = 1;
    }
    
    function createDepositContract(string _currencyCode, uint64 _granularity, uint64 _numContracts, uint32 _interest, uint _dateStarts, uint _dateEnds, uint _durationInDays, string _depositTermsLink, bytes32 _depositDataHash, uint _priceInWei) returns (address contractAddress)
    {
        // require (_dateStarts >= now);
        // require (_dateEnds > _dateStarts);
        require(msg.sender == owner);
        DepositContract newDepositContract = new DepositContract(this, _currencyCode, _granularity, _numContracts, _interest, _dateStarts, _dateEnds, _durationInDays, _depositTermsLink, _depositDataHash, _priceInWei);
        deposits[depositsCounter] = newDepositContract;
        depositsCounter = depositsCounter +1;
        contractAddress = newDepositContract;
    }
    
    function getDepositContract(uint _contractID) constant returns(address _contractAddress) {
        require (msg.sender == owner);
        address dep = deposits[_contractID];
        if (dep == 0x00)
            { throw;}
        _contractAddress = dep;
    }
    
    function maxDeposit() constant returns(uint256 c){
        c = depositsCounter - 1;
    }
    
    function getOwner() constant returns(address _owner){
        _owner = owner;
    }
    

}

contract DepositContract {
    
    string constant NoneString = ""; 
    bytes32 constant NoneBytes32 = bytes32(0);
    int64 constant NoneInt64 = int64(0);
    uint256 constant NoneUint256 = uint256(0);
    address constant NoneAddress = address(0x00);
    
    address issuer;
    // address public bank;
    string currencyCode;
    uint64 granularity;
    uint64 numContracts;
    uint32 interest; 
    uint dateStarts;
    uint dateEnds;
    uint durationInDays;
    string depositTermsLink;
    bytes32 depositDataHash;
    bool ended;
    uint priceInWei;
    IssuingBank bank;
    
    
    struct BoughtDepositDetails{
        uint internalID;
        address buyer;
        uint64 boughtUnits;
        uint boughtAt;
        DepositStatus status;
    }
    
    enum DepositStatus {Bought, ClaimRequested, ClaimIssued}
    event ClaimRequestEvent(uint indexed depositID);

    
    uint256 private boughtDepositsCounter = 0;
    // mapping(address => BoughtDepositDetails) deposits;
    mapping(uint => BoughtDepositDetails) deposits;
    // mapping(uint256 => address) deposits;
    
    function DepositContract(IssuingBank _bank, string _currencyCode, uint64 _granularity, uint64 _numContracts, uint32 _interest, uint _dateStarts, uint _dateEnds, uint _durationInDays, string _depositTermsLink, bytes32 _depositDataHash, uint _priceInWei)
    {
        // require(msg.sender == _bank.owner);
        issuer = msg.sender;
        bank = _bank; 
        currencyCode = _currencyCode;
        granularity = _granularity;
        numContracts = _numContracts;
        interest = _interest; 
        dateStarts = _dateStarts;
        dateEnds = _dateEnds;
        durationInDays = _durationInDays;
        depositTermsLink = _depositTermsLink;
        depositDataHash = _depositDataHash;
        priceInWei = _priceInWei;
        ended = false;
        boughtDepositsCounter = 1;
    }
    
    function buy(uint64 _numUnits) payable returns(bool _success, uint _depositID){
        require(!ended);
        // require(_numUnits <= numContracts);
        uint price = priceInWei*_numUnits;
        uint paid = msg.value;
        _success = false;
        require(paid == price);
        numContracts = numContracts - _numUnits;
        BoughtDepositDetails memory details = BoughtDepositDetails({
                internalID: boughtDepositsCounter,
                boughtUnits: _numUnits,
                boughtAt: now,
                buyer: msg.sender,
                status: DepositStatus.Bought
        });
        deposits[boughtDepositsCounter] = details;
        _depositID = boughtDepositsCounter;
        boughtDepositsCounter = boughtDepositsCounter+1;
        _success = true;
        if (numContracts <= 0){
            ended = true;
        }
        // require(now >= dateStarts);
        // require(now <= dateEnds);
        
    }
    
    function issuingBank() constant returns (address _owner){
        _owner = issuer;
    }
    
    function remaining() constant returns (uint64 _numContracts){
        _numContracts = numContracts;
    }
    
    function depositDetails() constant returns (string _currencyCode, uint64 _granularity, uint32 _interest, uint _dateStarts, uint _dateEnds, uint _durationInDays, uint _priceInWei){
        _currencyCode = currencyCode;
        _granularity = granularity;
        _interest = interest;
        _dateStarts = dateStarts;
        _dateEnds = dateEnds;
        _durationInDays= durationInDays;
        _priceInWei = priceInWei;
    }
    
    function maxBoughtDeposit() constant returns(uint256 c){
        c = boughtDepositsCounter - 1;
    }
    
    function getHistoryRecord(uint256 _depositID) constant returns(
        uint256 depositID,
        address buyer,
        uint boughtAt,
        uint64 numUnits )
        {
            BoughtDepositDetails det = deposits[_depositID];
            if (det.internalID != _depositID) throw;
            depositID = det.internalID;
            buyer = det.buyer;
            boughtAt = det.boughtAt;
            numUnits = det.boughtUnits;
        }
        
    function collectAmount(uint _amountInWei) returns (bool _success){
        require(msg.sender == bank.owner());
        // require(msg.sender == issuer);
        require(_amountInWei <= this.balance);
        bool res = issuer.send(_amountInWei);
        _success = res;
    }    
    
    function requestDepositSettlement(uint256 _depositID) returns (bool _success){
        _success = false;
        BoughtDepositDetails det = deposits[_depositID];
            if (det.internalID != _depositID) throw;
        require(det.buyer==msg.sender);
        uint expiration = det.boughtAt + durationInDays*1 days;
        require(now >= expiration);
        det.status = DepositStatus.ClaimRequested;
        deposits[_depositID] = det;
        ClaimRequestEvent(_depositID);
        _success = true;
    }
    
    function owningBankAddress () constant returns (address _bankAddress){
        _bankAddress = bank.owner();
    }
    
        function owningBankAddress2 () constant returns (address _bankAddress){
        _bankAddress = bank.getOwner();
    }
    
    function EmitDepositSettlement(uint256 _depositID, uint _amountInWei) returns (bool _success){
        address sender = msg.sender;
        address bankOwner = bank.getOwner();
        require(sender == bankOwner);
        _success = false;
        BoughtDepositDetails det = deposits[_depositID];
            if (det.internalID != _depositID) throw;
        // require(det.buyer==msg.sender);
        uint expiration = det.boughtAt + durationInDays*1 days;
        require(now >= expiration);
        // address buyer = det.buyer;
        bool res = det.buyer.send(_amountInWei);
        det.status = DepositStatus.ClaimIssued;
        deposits[_depositID] = det;
        _success = res;
    }
    
    
}