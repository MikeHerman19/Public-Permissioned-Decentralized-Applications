// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VPR_Registry_Contract {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    struct Value_Check {
        int value_check_id; 
        string attribute_id; 
        string predicate;
        string attribute_value; 
        string[] selected_issuers;
    }

    struct VPR {
        bytes4 function_id;
        Value_Check[] value_check_list;
        string CID;
    }

    VPR[] public registry;

    function addVPR(bytes4 _function_id, Value_Check[] memory _value_check_list, string memory _CID) public {
        // Create a new VPR in storage
        VPR storage newVPR = registry.push();
        newVPR.function_id = _function_id;
        newVPR.CID = _CID;

        // Manually copy each Required_Attribute to storage
        for (uint i = 0; i < _value_check_list.length; i++) {
            // Add a new Required_Attribute to the attribute array in storage
            Value_Check storage newValue_Check = newVPR.value_check_list.push();
            newValue_Check.attribute_id = _value_check_list[i].attribute_id;
            newValue_Check.predicate = _value_check_list[i].predicate;
            newValue_Check.attribute_value = _value_check_list[i].attribute_value;
            
            // Manually copy each selected_issuer to storage
            for (uint j = 0; j < _value_check_list[i].selected_issuers.length; j++) {
                newValue_Check.selected_issuers.push(_value_check_list[i].selected_issuers[j]);
            }
        }
    }
}
