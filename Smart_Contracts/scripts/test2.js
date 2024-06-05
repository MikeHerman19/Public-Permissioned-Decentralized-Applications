const AccessPolicy = artifacts.require("Policy_Storage");
const AnotherContract = artifacts.require("Test_Contract");

// Define the script
module.exports = async function(callback) {
    try {
        // Deploy the smart contract
        const policyStorageInstance = await AccessPolicy.deployed();
        const testContractInstance = await AnotherContract.deployed(); 

        const userAddress = "0xceefe3Ef3E922BbC8Fcb97236A7016C582DE0e83"; // Replace with your desired user address

        const testValues = [10, 20, 30];
        const funcIdHex = web3.utils.keccak256("testFunction"); // Vollständiger Hash der Funktionssignatur
        const funcId = funcIdHex.slice(0, 10);

        await policyStorageInstance.addPolicyEntry(funcId, testValues);

        const result = await testContractInstance.useGetPolicyEntry(funcId);

        console.log("Policy_Entry", result);

        //const owner = await attributeStorageInstance.Attribute_Storage(userAddress);
        //console.log("Owner:", owner);
        
        // Additional function calls can be made here
        
        // Finish script execution
        callback(null);
    } catch (error) {
        // Handle errors
        console.error("Error:", error);
        callback(error);
    }
};

