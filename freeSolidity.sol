pragma solidity ^0.5.1;

contract Service{
       
    uint serviceId;
    string serviceName;
    string serviceDescription;
    
   constructor (uint id, string memory _serviceName, string  memory _serviceDescription) public{
       serviceId = id;
       serviceName = _serviceName;
       serviceDescription = _serviceDescription;
   }
}

contract Client{
    
    uint clientId;
    string clientName;
    string clientPhoneNumber;
    string clientEmail;
    
    constructor (uint id, string memory clientNameMeta, string  memory cientPhoneNumberMeta, 
    string memory cientEmailMeta) public{
       clientId = id;
       clientName = clientNameMeta;
       clientPhoneNumber = cientPhoneNumberMeta;
       clientEmail = cientEmailMeta;
   }
}

contract ServiceProvider{
    
    uint servicerProviderId;
    string serviceProviderName;
    string serviceProviderPhoneNumber;
    string serviceProviderEmail;
    address serviceProviderAddress;
    uint rank;
    Service serviceProvided; //has a service
    
    constructor (uint id, string memory serviceProviderNameMeta, string  memory serviceProviderPhoneNumberMeta, 
    string memory serviceProviderEmailMeta,  address serviceProviderAddressMeta, uint rankMeta) public{
       servicerProviderId = id;
       serviceProviderName = serviceProviderNameMeta;
       serviceProviderPhoneNumber = serviceProviderPhoneNumberMeta;
       serviceProviderEmail = serviceProviderEmailMeta;
       serviceProviderAddress = serviceProviderAddressMeta;
       rank = rankMeta;
   }
   
   function assignServiceProvided (Service serviceProvidedMeta) public{
       serviceProvided = serviceProvidedMeta;
   }
}
    
    
contract FreeSolidityApplication{
    
    // struct Service{
    //     uint serviceId;
    //     string serviceName;
    //     string serviceDescription;
    //     }
    
    uint serviceIdCounter;
    uint serviceProviderIdCounter;
    uint clientIdCounter;
    address contractOwnerAddress;
    
    mapping (uint => Service) serviceMap;
    mapping (uint => ServiceProvider) serviceProviderMap;
    mapping (uint => Client) clientMap;
    
    // ServiceProvider registration fee payment
    modifier payServiceProviderRegistrationFee(){
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
       uint serviceId = serviceIdCounter++;
       Service newService = new Service(serviceId, _serviceName, _serviceDescription);
       serviceMap[serviceId] = newService;
   }
   
   function registerAsServiceProvider(string memory _serviceProviderName, 
   string memory _serviceProviderPhoneNumber, string memory _serviceProviderEmail, address _serviceProviderAddress,
   uint _rank) public payServiceProviderRegistrationFee {
       
       uint serviceProviderId = serviceProviderIdCounter++;
       ServiceProvider newServiceProvider = ServiceProvider (serviceProviderId, _serviceProviderName, _serviceProviderPhoneNumber,
       _serviceProviderEmail, _serviceProviderAddress);
       serviceProviderMap[serviceProviderId] = newServiceProvider;
   }
   
  function getServiceById(uint _serviceId) public returns (string memory _serviceName){
      return serviceMap[_serviceId].serviceName;
  }

// contract avaiableServiceProvider is avaiableService{
    
//     struct ServiceProvider{
//         uint servicerProviderId;
//         string serviceProviderName;
//         string serviceProviderPhoneNumber;
//         string serviceProviderEmail;
//         address serviceProviderAddress;
//         uint rank;
//         Service service;
//     }
  
}

