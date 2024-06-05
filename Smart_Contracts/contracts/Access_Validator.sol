// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPolicyStorage {
    function getPolicyEntry(bytes4 _funcId) external view returns (uint[] memory);
}

interface IAttributeStorage {
    function getAttributesFromAddress(address _user) external view returns(uint[] memory);
}

interface IApplicationLogic{
    function voteForCandidate(string memory candidate) external ; 
}

contract Access_Validator_Contract {

    address public owner;

    bytes4[] public functionsOfApplicationLogic;

    IPolicyStorage public policyStorage; 
    IAttributeStorage public attributeStorage;
    IApplicationLogic public applicationLogic;

    enum RuleEvaluation { DENY, PERMIT, NOTAPPLICABLE, INDETERMINATE }

    uint[] private environmentCheckNeccesary = [24] ; 




    constructor(address _policyStorageContractAddress, address _attributeStorageContractAddress, address _applicationLogicContractAddress) {
        owner = msg.sender;
        policyStorage = IPolicyStorage(_policyStorageContractAddress);
        attributeStorage = IAttributeStorage(_attributeStorageContractAddress);
        applicationLogic = IApplicationLogic(_applicationLogicContractAddress); 
    }

    function getAttributesFromEnvironment(uint AttrID) public view returns(uint) {
        if (AttrID == 1){
            //return current blocktime 
            return block.timestamp; 
        }else if (AttrID == 2){
            // Define further Environment Attributes
            return 4;
        }else {
            //AttrID is not defined
            return 0 ;
        }
        
    }

    function checkSubset(uint[] memory x, uint[] memory y) public pure returns (bool) {
        bool elementFound;

        // check if each element of x is in y 
        for (uint j = 0; j < x.length; j++) {
            elementFound = false; // Reset für jedes neue Element von x
            for (uint i = 0; i < y.length; i++) {
                if (x[j] == y[i]) {
                    elementFound = true;
                    break;
                }
            }
            // If a Element of X could not be found in y, return false 
            if (!elementFound) {
                return false;
            }
        }

        return true; // Alle Elemente von x sind mindestens einmal in y vorhanden
    }

    function evaluate(string memory _function_name, string memory candidate) public returns(bool){

        bytes4 funcID = bytes4(keccak256(bytes(_function_name)));

        uint[] memory policy =  policyStorage.getPolicyEntry(funcID);

        uint [] memory usersAttributes = attributeStorage.getAttributesFromAddress(msg.sender);

        bool permission = checkSubset(policy, usersAttributes);

        //check if Blocktime is need: 

        //bool timeneeded = checkSubset(environmentCheckNeccesary, policy);

        if(permission){
            (bool success, ) = address(applicationLogic).call(abi.encodeWithSignature(_function_name, candidate));
            require(success, "Function call failed.");
            return success;
        } else {
            // if no permission is granted
            return(false);
            //revert("You do not have permission to perform this action.");
             
        }
        
      



        

        //return RuleEvaluation.PERMIT;

    }


}
