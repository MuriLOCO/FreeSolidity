pragma solidity ^0.4.24;

contract HelloWorld {

    event HelloEvent(string _message, address _sender);

    function renderHelloWorld () public returns (string) {
        emit HelloEvent("Hello world", msg.sender);
        return "Hello world";
    }

}
