using Meadow.Contract;
using Meadow.JsonRpc.Types;
using Meadow.UnitTestTemplate;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Threading.Tasks;

namespace FreeSolidity
{
    // Inherit from 'ContractTest' to be provided with an RpcClient, 
    // Accounts, and several other useful features.
    [TestClass]
    public class MyContractTests : ContractTest
    {
        HelloWorld _contract;

        FreeSolidityApplication _contract1;
          
        // Method is ran before each test (all tests are ran in isolation).
        // This is an appropriate area to do contract deployment.
        protected override async Task BeforeEach()
        {
            // Deploy contract.
            _contract = await HelloWorld.New(RpcClient);
            _contract1 = await FreeSolidityApplication.New(RpcClient);
        }

        [TestMethod]
        public async Task ValidateCallResult()
        {
            // Call the renderHelloWorld function and get the return value.
            var callResult = await _contract.renderHelloWorld().Call();

            // Validate the return value is what we expect.
            Assert.AreEqual("Hello world", callResult);
        }

        [TestMethod]
        public async Task ValidateTransactionEventResult()
        {
            // Execute the renderHelloWorld function as a transaction and get the 
            var eventLog = await _contract.renderHelloWorld().FirstEventLog<HelloWorld.HelloEvent>();

            // Validate the event log arg is what we expect.
            Assert.AreEqual("Hello world", eventLog._message);
        }
        
        [TestMethod]
        public async Task ValidateTransactionSender()
        {
            // Execute a renderHelloWorld transaction and specify the 'from' account.
            var txParams = new TransactionParams { From = Accounts[5] };
            var eventLog = await _contract.renderHelloWorld().FirstEventLog<HelloWorld.HelloEvent>(txParams);

            // Validate the msg.sender as echoed back in our example contract.
            Assert.AreEqual(eventLog._sender, Accounts[5]);
        }

                [TestMethod]
        public async Task ValidateAddNewService()
        {
            // Call the addNewSupportedService function and get the return value.
            var callResult = await _contract1.addNewSupportedService("jose","jose as a service").Call();

            // Validate the return value is what we expect.
            Assert.AreEqual("success", callResult);
        }

        public async Task ValidateGetServiceById()
        {
            // Call the getServiceById function and get the return value.
            var callResult = await _contract1.getServiceById((Meadow.Core.EthTypes.UInt256)0).Call();

            // Validate the return value is what we expect.
            Assert.AreEqual("jose", callResult);
        }

        [TestMethod]
        public async Task ValidateFreeSolidityEventResult()
        {
            // Execute the getServiceById function as a transaction and get the 
            var eventLog = await _contract1.getServiceById((Meadow.Core.EthTypes.UInt256)0).FirstEventLog<FreeSolidityApplication.HelloEvent>();

            // Validate the event log arg is what we expect.
            Assert.AreEqual("someone looked up a service by id", eventLog._message);
        }
        
        [TestMethod]
        public async Task ValidateFreeSolidityTransactionSender()
        {
            // Execute a getServiceById transaction and specify the 'from' account.
            var txParams = new TransactionParams { From = Accounts[5] };
            var eventLog = await _contract1.getServiceById(0).FirstEventLog<HelloWorld.HelloEvent>(txParams);

            // Validate the msg.sender as echoed back in our example contract.
            Assert.AreEqual(eventLog._sender, Accounts[5]);
        }
    }
}
