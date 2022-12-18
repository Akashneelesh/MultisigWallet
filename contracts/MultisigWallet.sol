pragma solidity ^0.8.9;

import "./InterfaceWallet.sol";
import "./AccessControl.sol";
import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MultisigWallet is AccessControl{
    using SafeMath for uint256;

    struct Transaction {
        bool executed;
        address destination;
        uint256 value;
        bytes data;
    }

    uint256 public transactionCount;
    mapping(uint256 => Transaction) public transactions;
    Transaction[] public _validTransactions;

    mapping(uint256 => mapping(address => bool)) public confirmations;

    fallback() external payable {
        if(msg.value > 0) {
            emit Deposit(msg.sender, msg.value);
        }
    }

    receive() external payable {
        if(msg.value > 0) {
            emit Deposit(msg.sender, msg.value);
        }

    }

    modifier isOwnerAuth(address owner) {
        require(isOwner[owner]== true,"Not authorized for this.");
        _;
    }

    modifier isConfirmedAuth(uint256 transactionId,address owner) {
        require(confirmations[transactionId][owner] == false,"You have already confirmed this transaction");
        _;
    }
    modifier isExecutedMod(uint256 transactionId){
        require(transactions[transactionId].executed == false,
        "This transaction has already been executed.");
        _;
    }


    constructor(address[] memory _owners) AccessControl(_owners){

    }

    function submitTransaction(address destination,uint256 value,bytes memory data) public isOwnerAuth(msg.sender) returns (uint256 transactionId){
        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            destination: destination,
            value: value,
            data: data,
            executed: false
        });
        transactionCount +=1;
        emit Submission(transactionId);

        confirmTransaction(transactionId);


    }

    function confirmTransaction(uint256 transactionId) public isOwnerAuth(msg.sender) isConfirmedAuth(transactionId,msg.sender) addressNotNull(transactions[transactionId].destination){
        confirmations[transactionId][msg.sender] = true;
        emit Confirmation(msg.sender, transactionId);

        executeTransaction(transactionId);
    }

    function executeTransaction(uint256 transactionId) public isOwnerAuth(msg.sender) isExecutedMod(transactionId){
        uint256 count = 0;
        bool quorumReached;

        for(uint256 i = 0; i<owners.length;i++) {
            if(confirmations[transactionId][owners[i]])
                count+=1;
            
            if(count >= quorum)
                quorumReached= true;
        }

        if(quorumReached) {
            Transaction storage txn = transactions[transactionId];
            txn.executed = true;

            (bool success, ) = txn.destination.call{
                value: txn.value
            } (txn.data);

            if(success) {
                _validTransactions.push(txn);
                emit Execution(transactionId);
            } else {
                emit ExecutionFailure(transactionId);
                txn.executed = false;
            }
        }
    }

    function revokeTransaction(uint256 transactionId) external isOwnerAuth(msg.sender) isConfirmedAuth(transactionId,msg.sender) isExecutedMod(transactionId) addressNotNull(transactions[transactionId].destination) {
        confirmations[transactionId][msg.sender] = false;
        emit Revocation(msg.sender, transactionId);
    }

    function getOwners() external view returns (address[] memory) {
        return owners;
    }

    function getValidTranasactions() external view returns (Transaction[] memory){
        return _validTransactions;
    }

    function getQuorum() external view returns (uint256) {
        return quorum;
    }
    

}