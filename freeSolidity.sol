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
        uint rankAvaliations;
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
    
   //This function converts strings to the Ethereum hashes and compares the resulting values
   function compareStrings (string memory a, string memory b) private pure returns (bool){
       return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
   }
   
    function addNewSupportedService(string memory _serviceName, string memory _serviceDescription) public {
       require(contractOwnerAddress == msg.sender);
       uint serviceId = serviceIdCounter++;
       serviceMap[serviceId] = Service(serviceId, _serviceName, _serviceDescription);
    }

   function registerAsServiceProvider(string memory _serviceProviderName, string memory _serviceProviderPhoneNumber,
   string memory _serviceProviderEmail) public payServiceProviderRegistrationFee payable{
       
       uint serviceProviderId = serviceProviderIdCounter++;
       serviceProviderMap[serviceProviderId] = ServiceProvider(serviceProviderId, _serviceProviderName, _serviceProviderPhoneNumber,
       _serviceProviderEmail, msg.sender, 5, 0);
   }

    //WIP: register as client (Sidd)
    function registerAsClient(string memory _clientName, string memory _clientPhoneNumber, string memory _clientEmail) public {
        uint clientId = clientIdCounter++;
        uint  initialRank = 5;
        clientMap[clientId] = Client(clientId,_clientName,_clientPhoneNumber,_clientEmail,msg.sender,initialRank);
    }

    //TODO: match client with service provider (specify service type)

   //This function add rank to the service provider (Jose)
    function rankServiceProvider(string memory _servicePoviderName, uint _rank) public{
        uint currentRank = 0;
        uint currentRankAvaliations = 0;
        uint pointer = 0;
        for(uint i = 1; i < serviceProviderIdCounter; i++){
            if(compareStrings(serviceProviderMap[serviceProviderIdCounter].serviceProviderName, _servicePoviderName)){
               currentRank = serviceProviderMap[serviceProviderIdCounter].rank;
               currentRankAvaliations = serviceProviderMap[serviceProviderIdCounter].rankAvaliations;
               pointer = i;
               break;
            }
        }
        currentRankAvaliations++;
        currentRank = (currentRank + _rank) / currentRankAvaliations;
        serviceProviderMap[pointer].rank = currentRank;
        serviceProviderMap[pointer].rankAvaliations = currentRankAvaliations;
    }

    //Jose
    //Returning lists in Solidity are still not supported and very expensive, so a solution found is to ask the user to
    //choose a pointer and check if the service exist or not, in this case the user choose a string and we return the service description
    function getServiceDescriptionOfAServiceByName(string memory _serviceName) public view returns (string memory){
        for(uint i = 1; i < serviceIdCounter; i++){
            if(compareStrings(serviceMap[i].serviceName, _serviceName)){
                return serviceMap[i].serviceDescription;
            }
        }
        return "Service does not exist.";
    }
}