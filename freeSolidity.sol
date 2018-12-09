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
       serviceIdCounter = 0;
       serviceProviderIdCounter = 0;
       clientIdCounter = 0;
   }
   
   function addNewSupportedService(string memory _serviceName, string memory _serviceDescription) public {
       require(contractOwnerAddress == msg.sender);
    
    Service memory service;
    
    uint serviceId = serviceIdCounter++;
    service.serviceId = serviceId;
    serviceMap[serviceId] = Service(serviceId, _serviceName, _serviceDescription);
   }
   
//   function registerAsServiceProvider(string memory _serviceProviderName, 

   
    function getServiceById(uint _serviceId) public view returns (string memory _serviceName){
        return serviceMap[_serviceId].serviceName;
    }
}

