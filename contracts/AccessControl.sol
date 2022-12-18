// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract AccessControl {
    using SafeMath for uint256;


    event Deposit(address indexed sender, uint256 value);
    event Submission(uint256 indexed transactionId);
    event Confirmation(address indexed sender, uint256 indexed transactionId);
    event Execution(uint256 indexed transactionId);
    event ExecutionFailure(uint256 indexed transactionId);
    event Revocation(address indexed sender, uint256 indexed transactionId);
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);
    event QuorumUpdate(uint256 quorum);
    event AdminTransfer(address indexed newAdmin);

    address public admin;

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 quorum;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Cant be accessed only by admin");
        _;
    }
    
    modifier addressNotNull(address _address){
        require(_address != address(0), "Address Does not exist");
        _;
    }
    modifier ownerExists(address owner){
        require(isOwner[owner] == true, "This owner does not exist");
        _;
    }
    modifier ownerDoesntExist(address owner) {
        require(isOwner[owner] == false, "This owner exists");
        _;
    }


    constructor(address[] memory _owners) {
        admin = msg.sender;
        require(_owners.length >= 3, "There should be atleast 3 addresses");
        for(uint256 i=0; i< _owners.length; i++){
            isOwner[_owners[i]]= true;
        }

        owners = _owners;
        uint256 num = SafeMath.mul(owners.length, 60);
        quorum = SafeMath.div(num, 100);

    }

    function addOwner(address owner) public onlyAdmin addressNotNull(owner) ownerDoesntExist(owner) {
        isOwner[owner] = true;
        owners.push(owner);

        emit OwnerAddition(owner);
        updateQuorum(owners);

    }

    function removeOwner(address owner) public onlyAdmin addressNotNull(owner) ownerExists(owner) {

        isOwner[owner] = false;
        for(uint256 i =0;i<owners.length -1; i++)
            if(owners[i]== owner){
                owners[i] = owners[owners.length-1];
                break;
            }
        owners.pop();

        updateQuorum(owners);
        
    }

    function transferOwner(address _from, address _to) public onlyAdmin addressNotNull(_from) addressNotNull(_to) ownerExists(_from) ownerDoesntExist(_to){
        for(uint256 i = 0; i < owners.length; i++)
            if(owners[i] == _from){
                owners[i] = _to;
                break;
            }
        isOwner[_from] = false;
        isOwner[_to] = true;

        emit OwnerRemoval(_from);
        emit OwnerAddition(_to);
    }

    function renounceAdmin(address newAdmin) public onlyAdmin {
        admin = newAdmin;
        emit AdminTransfer(newAdmin);
    }

    function updateQuorum(address[] memory _owners) internal {
        uint256 num = SafeMath.mul(_owners.length,60);
        quorum = SafeMath.div(num,100);
        emit QuorumUpdate(quorum);
    }
}
