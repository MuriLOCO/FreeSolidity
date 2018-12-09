pragma solidity ^0.4.25;
contract availableService{
    
    uint counter;
    address contractOnwerAddress;
    
    struct Service{
        uint serviceId;
        string serviceName;
        string serviceDescription;
    }
        
    mapping (uint => Service) services;
   
    constructor() public {
        contractOnwerAddress = msg.sender;
        counter = 0;
    }
   
    function createService(string memory _serviceName, string memory _serviceDescription) public {
        require(contractOnwerAddress == msg.sender,"only the owner can create a service");
        uint serviceId = counter++;
        services[serviceId] = Service(serviceId, _serviceName, _serviceDescription);
    }
   
    function getServiceById(uint _serviceId) public view returns (string memory _serviceName){
        return services[_serviceId].serviceName;
    }
}

contract availableServiceProvider is availableService{
    
    struct ServiceProvider{
        uint servicerProviderId;
        string serviceProviderName;
        string serviceProviderPhoneNumber;
        string serviceProviderEmail;
        address serviceProviderAddress;
        uint rank;
        Service service;
    }
  
}

contract customer{
    
    struct Client{
        uint clientId;
        string clientName;
        string clientPhoneNumber;
        string clientEmail;
    }
}