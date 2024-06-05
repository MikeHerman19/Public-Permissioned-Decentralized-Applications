const Policy_Storage = artifacts.require("Policy_Storage_Contract");
const Attribute_Storage = artifacts.require("Attribute_Storage_Contract");
const Application_Logic = artifacts.require("Application_Logic_Contract");
const Access_Validator = artifacts.require("Access_Validator_Contract");
const VPR_Registry = artifacts.require("VPR_Registry_Contract");
const Registration_Validator= artifacts.require("Registration_Validator_Contract")
const VSC = artifacts.require("Verifier"); 

const proof = require("../proof.json");

// Define the script
module.exports = async function(callback) {
    try {
        // Deploy the smart contract
        const deployedVSC = await VSC.deployed();
        const deployedRegistrationValidator = await Registration_Validator.deployed(); 
        const deployedAttributeStorage = await Attribute_Storage.deployed();
        const deployedPolicyStorage = await Policy_Storage.deployed(); 
        const deployedAccessValidator = await Access_Validator.deployed(); 
        const deployedApplicationLogic = await Application_Logic.deployed();

        const userAddress = "0xceefe3Ef3E922BbC8Fcb97236A7016C582DE0e83"; // Replace with your desired user address
        console.log(1);

        const owner = await deployedRegistrationValidator.owner();
        console.log("RegistrationValidator Owner:", owner );
        console.log(userAddress); 
        
        console.log(2)

        const result = await deployedRegistrationValidator.registration(proof.proof,proof.inputs,1,{ from: userAddress });
        const txHash = result.tx;
        const txReceipt = await web3.eth.getTransactionReceipt(txHash);
        console.log('Gas used for Registration:', txReceipt.gasUsed);

        

        //console.log("Proof Evaluation", result);

        const userAttributes = await deployedAttributeStorage.getAttributesFromAddress(userAddress);
        console.log("User Attributes:", userAttributes);

        const result1 = await deployedPolicyStorage.addPolicyEntry(web3.utils.keccak256("voteForCandidate(string)").slice(0,10), [17,9,1998]);
        const txHash1 = result1.tx;
        const txReceipt1 = await web3.eth.getTransactionReceipt(txHash1);
        console.log('Gas used for adding Policy:', txReceipt1.gasUsed);



        const policy = await deployedPolicyStorage.getPolicyEntry(web3.utils.keccak256("voteForCandidate(string)").slice(0,10));

    

        console.log(policy)

        const hatfunktioniert = await deployedAccessValidator.evaluate("voteForCandidate(string)", "Alice"); 
        console.log(hatfunktioniert);

        const txHash2 = hatfunktioniert.tx;
        const txReceipt2 = await web3.eth.getTransactionReceipt(txHash2);
        console.log('Gas used for evaluation+ application function call :', txReceipt2.gasUsed);




        const anzahl = await deployedApplicationLogic.totalVotesFor("Alice");
        console.log("Anzahl an anrufen für Alice:", anzahl);





        //voteForCandidate


        

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

