pragma solidity ^0.4.25;
    
contract FreeSolidityApplication{

    event HelloEvent(string _message, address _sender);
    
    struct Service{
        uint serviceId;
        string serviceName;
        string serviceDescription;
    }
        
    struct Client{
        uint clientId;
        string clientName;
        string clientPhoneNumber;
        string clientEmail;
        address clientAddress;
        uint rank;
    }
    
    struct ServiceProvider{
        uint servicerProviderId;
        string serviceProviderName;
        string serviceProviderPhoneNumber;
        string serviceProviderEmail;
        address serviceProviderAddress;
        uint rank;
    }
    
    uint serviceIdCounter;
    uint serviceProviderIdCounter;
    uint clientIdCounter;
    address contractOwnerAddress;
    
    mapping (uint => Service) serviceMap;
    mapping (uint => ServiceProvider) serviceProviderMap;
    mapping (uint => Client) clientMap;
    
    // ServiceProvider registration fee payment
    modifier payServiceProviderRegistrationFee() {
        require (msg.value >= 2000000000000000000);
        contractOwnerAddress.transfer(msg.value);
        _;
    }
   
    constructor() public{
       contractOwnerAddress = msg.sender;
       serviceIdCounter = 1;
       serviceProviderIdCounter = 1;
       clientIdCounter = 1;
    }
   
    function addNewSupportedService(string memory _serviceName, string memory _serviceDescription) public returns (string memory){
       require(contractOwnerAddress == msg.sender);
       uint serviceId = serviceIdCounter++;
       serviceMap[serviceId] = Service(serviceId, _serviceName, _serviceDescription);
       return "success";
    }

    //TODO: Yasser
    //function registerAsServiceProvider(string memory _serviceProviderName,

    //WIP: register as client (Sidd)
    function registerAsClient(string memory _clientName, string memory _clientPhoneNumber, string memory _clientEmail) public {
        uint clientId = clientIdCounter++;
        uint  initialRank = 5;
        clientMap[clientId] = Client(clientId,_clientName,_clientPhoneNumber,_clientEmail,msg.sender,initialRank);
    }

    //TODO: match client with servive provider (specify service type and rank)
    //TODO: add rank functionallty

    //TODO: return list of services(Jose)
    function getServiceById(uint _serviceId) public view returns (string memory _serviceName){
        emit HelloEvent("someone looked up a service by id", msg.sender);
        _serviceName = serviceMap[_serviceId].serviceName;
        return _serviceName;
    }
}