pragma solidity ^0.5.1;
    
contract FreeSolidityApplication{
    
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
    address payable contractOwnerAddress;
    
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
   
   function addNewSupportedService(string memory _serviceName, string memory _serviceDescription) public {
       require(contractOwnerAddress == msg.sender);
       uint serviceId = serviceIdCounter++;
       serviceMap[serviceId] = Service(serviceId, _serviceName, _serviceDescription);
       }
   //TODO: Yasser
   //function registerAsServiceProvider(string memory _serviceProviderName, 

//TODO: register as client (Sidd)
//TODO: match client with servive provider (specify service type and rank)
//TODO: add rank functionallty

//TODO: return list of services(Jose)   
    function getServiceById(uint _serviceId) public view returns (string memory _serviceName){
        _serviceName = serviceMap[_serviceId].serviceName;
        return _serviceName;
    }
}

