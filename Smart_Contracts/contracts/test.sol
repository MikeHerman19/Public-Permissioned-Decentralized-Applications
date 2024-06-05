pragma solidity ^0.8.0;


interface IPolicyStorage {
    function getPolicyEntry(bytes4 _funcId) external view returns (int[] memory);
}


contract Test_Contract {




    IPolicyStorage public policyStorage; 
    //IAttributeStorage attributeStorage; 

    //enum RuleEvaluation { DENY, PERMIT, NOTAPPLICABLE, INDETERMINATE }


    constructor(address _policyContractAddress) {
        //owner = msg.sender;
        policyStorage = IPolicyStorage(_policyContractAddress);

    }

    function useGetPolicyEntry(bytes4 _funcId) public view returns (int[] memory) {
        return policyStorage.getPolicyEntry(_funcId);
    }

}