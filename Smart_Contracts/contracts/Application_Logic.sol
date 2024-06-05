// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Application_Logic_Contract {

    address public accessValidatorContract; 


    mapping (string => uint256) public votesReceived;
    string[] public candidateList;

    function setAccessValidatorContract(address _addr) public {
        // Zusätzliche Sicherheitsprüfungen sollten hier implementiert werden
        accessValidatorContract = _addr;
    }

    constructor(string[] memory candidateNames) {
        candidateList = candidateNames;
    }

    function voteForCandidate(string memory candidate) public {
        
        require(validCandidate(candidate), "Not a valid candidate.");
        
        votesReceived[candidate] += 1;
        
    }

     function totalVotesFor(string memory candidate) public view returns (uint256) {
        require(validCandidate(candidate), "Not a valid candidate.");
        return votesReceived[candidate];
    }

    function validCandidate(string memory candidate) internal view returns (bool) {
        for(uint i = 0; i < candidateList.length; i++) {
            if (keccak256(bytes(candidateList[i])) == keccak256(bytes(candidate))) {
                return true;
            }
        }
        return false;
    }


}
