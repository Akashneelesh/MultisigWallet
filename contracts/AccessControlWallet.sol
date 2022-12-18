pragma solidity ^0.8.9;

import "./InterfaceWallet.sol";
import "./AccessControl.sol";
import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";

contract AccessControlWallet is AccessControl {
    using SafeMath for uint256;

    InterfaceWallet _walletInterface;

    constructor(InterfaceWallet _wallet, address[] memory _owners) AccessControl(_owners){
        _walletInterface = InterfaceWallet(_wallet);
        admin = msg.sender;
    }

    function getOwners() external view returns (address[] memory){
        return owners;
    }

    function getAdmin() external view returns (address) {
        return admin;
    }

}
