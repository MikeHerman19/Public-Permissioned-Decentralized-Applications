// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//interface IAttributeStorage {
  //      function getPolicyEntry(bytes4 _funcId) external view returns (int[] memory);
    //}

contract Attribute_Storage_Contract {

    address public registrationValidatorContract;

    address public owner;

    int value_check_id; 

    mapping(address => uint[]) public Attribute_Storage;

    struct attribute{
        uint bestandene_value_checks; 
    }


    constructor() {
        owner = msg.sender;
    }


    function setRegistrationValidatorContract(address _addr) public {
        require(msg.sender == owner, "Only the owner can call this function");
        registrationValidatorContract = _addr;
    }    

    

    function modifyAttributeStorage(address _subject, uint[] memory _inputs) public {
        require(msg.sender == registrationValidatorContract, "Only the owner can call this function"); // Only Registration Validator should be able to call this 

        uint[] storage subjectAttributes = Attribute_Storage[_subject];
        
        // Clear existing attributes for the subject
        //delete subjectAttributes;
        
        // Copy each element from _inputs to storage
        for (uint i = 0; i < _inputs.length; i++) {
            subjectAttributes.push(_inputs[i]);
        }
    }
    
    function getAttributesFromAddress(address _user) public view returns(uint[] memory) {
        return Attribute_Storage[_user];
    }

}


