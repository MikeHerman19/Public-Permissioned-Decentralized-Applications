// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPolicyStorage {
        function getPolicyEntry(bytes4 _funcId) external view returns (int[] memory);
    }


contract Policy_Storage_Contract{

    
    struct attribute{
        string bestandene_value_checks; 
    }

    struct value_check_liste{
        uint[] value_check_id; 
    }

    struct Value_Check {
        string value_check_id;
        string attribute_id; 
        string predicate;
        string attribute_value; 
        string[] selected_issuers;
    }

    mapping(bytes4 => uint[]) internal Policy_Storage;
    //mapping(address => attribute[]) public 

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function addPolicyEntry(bytes4 _funcId, uint[] memory _valueCheckIds) public {
        // Can also be used for existing entries in the Policy Storage
        require(msg.sender == owner , "Only the owner is able to call this function");
        for (uint i = 0; i < _valueCheckIds.length; i++) {
            Policy_Storage[_funcId].push(_valueCheckIds[i]);
        }
    }

  //  function addValueCheckIdsToExistingPolicy(bytes4 _funcId, uint[] memory _newIds) public {
   //     value_check_liste storage entry = Policy_Storage[_funcId];
   //     for (uint i = 0; i < _newIds.length; i++) {
  //          entry.value_check_id.push(_newIds[i]);
    //    }
    //}

 //   function removeValueCheckIdFromExistingPolicy(bytes4 _funcId, uint _idToRemove) public {
  //      require(msg.sender == owner, "Only the owner can call this function"); // Only Registration Validator should be able to call this
  //      value_check_liste storage entry = Policy_Storage[_funcId];
  //      uint length = entry.value_check_id.length;
  //      for (uint i = 0; i < length; i++) {
   //         if (entry.value_check_id[i] == _idToRemove) {
        //        entry.value_check_id[i] = entry.value_check_id[length - 1];
       //         entry.value_check_id.pop();
      //          break;
 //           }
 //       }
 //   }

    function getPolicyEntry(bytes4 _funcId) external view returns (uint[] memory) {
        return Policy_Storage[_funcId];
    }
    

}