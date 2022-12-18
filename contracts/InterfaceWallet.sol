pragma solidity ^0.8.9;

interface InterfaceWallet{
    function addowner(address owner) external;
    function removeOwner(address owner) external;
    function transferOwner(address _from, address _to) external;
    function confirmTransaction(uint256 transactionId) external;
    function executeTransaction(uint256 transactionId) external;
    function revokeTransaction(uint256 transactionId) external;

}