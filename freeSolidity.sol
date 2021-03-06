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
        bytes32 secret; //This is used to so the service provider can get paid
    }
    
    struct ServiceProvider{
        uint serviceProviderId;
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
    
   //Converts strings to the Ethereum hashes and compares the resulting values
   function compareStrings (string memory a, string memory b) private pure returns (bool){
       return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
   }
   
   //Adds new supported server
    function addNewSupportedService (string memory _serviceName, string memory _serviceDescription) public {
       
       require(contractOwnerAddress == msg.sender);
       uint serviceId = serviceIdCounter++;
       serviceMap[serviceId] = Service(serviceId, _serviceName, _serviceDescription);
    }
    
    //Register a service provider
   function registerAsServiceProvider (string memory _serviceProviderName, string memory _serviceProviderPhoneNumber,
   string memory _serviceProviderEmail, string memory _serviceName, uint _ethAmount) public payable payServiceProviderRegistrationFee {
       
       uint serviceProviderId = serviceProviderIdCounter++;
       serviceProviderMap[serviceProviderId] = ServiceProvider(serviceProviderId, _serviceProviderName, _serviceProviderPhoneNumber,
       _serviceProviderEmail, _serviceName, msg.sender, msg.sender, 5, 0, _ethAmount);
   }
   
   //Returns the last added Service Provider for testing pourposes
   function showLastRegisteredServiceProvider() view public returns(address){
       return serviceProviderMap[serviceProviderIdCounter-1].serviceProviderAddress;
   }

    //Register as client
    function registerAsClient (string memory _clientName, string memory _clientPhoneNumber, string memory _clientEmail, string memory _secret) public {
        uint clientId = clientIdCounter++;
        uint  initialRank = 5;
        clientMap[clientId] = Client(clientId,_clientName,_clientPhoneNumber,_clientEmail,
        msg.sender, initialRank, keccak256(abi.encodePacked(_secret)));
    }

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
    
    //Match the client to the service provider
    function matchClientToServiceProvider (string memory _serviceName) public clientIsRegistered returns (address matchedServiceProviderAddress){
        
        ServiceProvider memory tempServiceProvider = ServiceProvider(0, 'tempName', '000-000-0000',
       'temp@temp.com', _serviceName,msg.sender, msg.sender, 0 , 0, 1000);
        
        for (uint j = 0; j < serviceProviderIdCounter; j++){
            if(compareStrings(serviceProviderMap[j].serviceName, _serviceName)){
                if((serviceProviderMap[j].rank >= tempServiceProvider.rank) && 
                (serviceProviderMap[j].rate <= tempServiceProvider.rate)){
                    tempServiceProvider = serviceProviderMap[j];
                }
            }
        }
        serviceProviderMap[tempServiceProvider.serviceProviderId].clientWalletAddress = msg.sender;
        
        return tempServiceProvider.serviceProviderAddress;
    }
    
    //Check if the client matched to the service provider
   function checkIfClientMatchedToServiceProvider(string memory _serviceName) view public returns(string memory){
        
        for(uint i = 1; i < serviceProviderIdCounter; i++){
            if((serviceProviderMap[i].clientWalletAddress == msg.sender) && 
            compareStrings(serviceProviderMap[i].serviceName, _serviceName)){
                return serviceProviderMap[i].serviceProviderName;
            }
        }       
       return "Could not find a Match.";
    }    
    
    //Looks up the service provider by address
    function lookUpServiceProviderByAddress (address _serviceProviderAddress) view public returns (string memory) {
        
        string  memory info = '';
        
        for(uint i = 1; i < serviceProviderIdCounter; i++){
            if(serviceProviderMap[i].serviceProviderAddress == _serviceProviderAddress){
                info = string(abi.encodePacked(
                    " ServiceProviderName: ", serviceProviderMap[i].serviceProviderName," ServiceProviderPhoneNumber: ",
                serviceProviderMap[i].serviceProviderPhoneNumber," ServiceProviderEmail: ",
                serviceProviderMap[i].serviceProviderEmail," ServiceName: "));
                return info;
            }
        }
        return "Service Provider does not exist.";
    }
    
     //Starts the job, look for the SP by address and fetch the rate, sends ether to the contract and clients sets secret
    function startJob(address _serviceProviderAddress, string memory _secret) clientIsRegistered payable public{
        ServiceProvider memory serviceProvider;
        for(uint i = 1; i < serviceProviderIdCounter; i++){
            if(serviceProviderMap[i].serviceProviderAddress == _serviceProviderAddress){
                serviceProvider = serviceProviderMap[i];
                break;
            }
        }
       require(msg.value >= serviceProvider.rate);
       for(uint i = 1; i < clientIdCounter; i++){
            if(clientMap[i].clientAddress == msg.sender){
                clientMap[i].secret = keccak256(abi.encodePacked(_secret));
                break;
            }
        }
    }
    
    //Claims the ether which is stored in the contract
    function claim(string memory _secret) public{
        ServiceProvider memory serviceProvider;
        for(uint i = 1; i < serviceProviderIdCounter; i ++){
             if(serviceProviderMap[i].serviceProviderAddress == msg.sender){
                serviceProvider = serviceProviderMap[i];
                break;
            }
        }
        bytes32 secret;
         for(uint i = 1; i < clientIdCounter; i++){
            if(clientMap[i].clientAddress == serviceProvider.clientWalletAddress){
                //clientMap[i].secret = keccak256(abi.encodePacked(_secret));
                secret = clientMap[i].secret;
                break;
            }
        }
        require(keccak256(abi.encodePacked(_secret)) == secret);
        msg.sender.transfer(serviceProvider.rate);
    
    }
}