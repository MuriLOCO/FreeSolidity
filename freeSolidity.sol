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
        string serviceName;
        address serviceProviderAddress;
        address clientWalletAddress;
        uint rank;
        uint rankEvaluation;
        uint rate;
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
    
    // Client needs to be registered in order to be matched to a ServiceProvider
    modifier clientIsRegistered() {
        for(uint i = 1; i < clientIdCounter; i++){
            if(clientMap[i].clientAddress == msg.sender){
                _;
            } else {
                continue;
            }
        }
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
   
    function addNewSupportedService (string memory _serviceName, string memory _serviceDescription) public {
       
       require(contractOwnerAddress == msg.sender);
       uint serviceId = serviceIdCounter++;
       serviceMap[serviceId] = Service(serviceId, _serviceName, _serviceDescription);
    }
    
   function registerAsServiceProvider (string memory _serviceProviderName, string memory _serviceProviderPhoneNumber,
   string memory _serviceProviderEmail, string memory _serviceName, uint _ethAmount) public payable payServiceProviderRegistrationFee {
       
       uint serviceProviderId = serviceProviderIdCounter++;
       serviceProviderMap[serviceProviderId] = ServiceProvider(serviceProviderId, _serviceProviderName, _serviceProviderPhoneNumber,
       _serviceProviderEmail, _serviceName, msg.sender, msg.sender, 5, 0, _ethAmount);
   }
   
   //This function returns the last added Service Provider for testing pourposes (Jose)
   function showLastRegisteredServiceProvider() view public returns(address){
       return serviceProviderMap[serviceProviderIdCounter-1].serviceProviderAddress;
   }

    //WIP: register as client (Sidd)
    function registerAsClient (string memory _clientName, string memory _clientPhoneNumber, string memory _clientEmail) public {
        uint clientId = clientIdCounter++;
        uint  initialRank = 5;
        clientMap[clientId] = Client(clientId,_clientName,_clientPhoneNumber,_clientEmail,
        msg.sender, initialRank);
    }

    //TODO: match client with service provider (specify service type)

   //This function add rank to the service provider (Jose)
    function rankServiceProvider (string memory _servicePoviderName, uint _rank) public{
        uint currentRank = 0;
        uint currentRankEvaluations = 0;
        uint pointer = 0;
        for(uint i = 1; i < serviceProviderIdCounter; i++){
            if(compareStrings(serviceProviderMap[serviceProviderIdCounter].serviceProviderName, _servicePoviderName)){
               currentRank = serviceProviderMap[serviceProviderIdCounter].rank;
               currentRankEvaluations = serviceProviderMap[serviceProviderIdCounter].rankEvaluation;
               pointer = i;
               break;
            }
        }
        currentRankEvaluations++;
        currentRank = (currentRank + _rank) / currentRankEvaluations;
        serviceProviderMap[pointer].rank = currentRank;
        serviceProviderMap[pointer].rankEvaluation = currentRankEvaluations;
    }

    //Jose
    //Returning lists in Solidity are still not supported and very expensive, so a solution found is to ask the user to
    //choose a pointer and check if the service exist or not, in this case the user choose a string and we return the service description
    function getServiceDescriptionOfAServiceByName (string memory _serviceName) public view returns (string memory){
        for(uint i = 1; i < serviceIdCounter; i++){
            if(compareStrings(serviceMap[i].serviceName, _serviceName)){
                return serviceMap[i].serviceDescription;
            }
        }
        return "Service does not exist.";
    }
    
    function matchClientToServiceProvider (string memory _serviceName) public clientIsRegistered returns (address matchedServiceProviderAddress){
        
        ServiceProvider memory tempServiceProvider = ServiceProvider(0, 'tempName', '000-000-0000',
       'temp@temp.com', _serviceName,msg.sender, msg.sender, 0 , 0, 1000);
        
        for (uint j = 0; j < serviceProviderIdCounter; j++){
            if(compareStrings(serviceProviderMap[j].serviceName, _serviceName)){
                if((serviceProviderMap[j].rank >= tempServiceProvider.rank) && 
                (serviceProviderMap[j].rate <= tempServiceProvider.rate)){
                    serviceProviderMap[j].clientWalletAddress = msg.sender;
                }
            }
        }
        return tempServiceProvider.serviceProviderAddress;
    }
    
   function checkIfClientMatchedToServiceProvider() view public returns(string memory){
        for(uint i = 1; i < serviceProviderIdCounter; i++){
            if(serviceProviderMap[i].clientWalletAddress == msg.sender){
                return serviceProviderMap[i].serviceProviderName;
            }
        }       
       return "Could not find a Match.";
   }    
    
    function lookUpServiceProviderByAddress (address _serviceProviderAddress) view public returns (string memory) {
        
        string  memory info = '';
        
        for(uint i = 1; i < serviceProviderIdCounter; i++){
            if(serviceProviderMap[i].serviceProviderAddress == _serviceProviderAddress){
                info = strConcat(serviceProviderMap[i].serviceProviderName, serviceProviderMap[i].serviceProviderPhoneNumber);
                info = strConcat(info,serviceProviderMap[i].serviceProviderEmail);
                return info;
            }
        }
        return "Service Provider does not exist.";
    }
    
    function strConcat(string memory _a, string memory _b) internal pure returns (string memory concatenatedString) {
        bytes memory bytes_a = bytes(_a);
        bytes memory bytes_b = bytes(_b);
        string memory string_ab = new string(bytes_a.length + bytes_b.length);
        bytes memory bytes_ab = bytes(string_ab);
        uint k = 0;
        for (uint i = 0; i < bytes_a.length; i++) bytes_ab[k++] = bytes_a[i];
        return string(bytes_ab);
    }
}