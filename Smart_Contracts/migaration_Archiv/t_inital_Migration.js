import proof from "../proof.json";
console.log(proof);

const Policy_Storage = artifacts.require("Policy_Storage_Contract");
const Attribute_Storage = artifacts.require("Attribute_Storage_Contract");
const Application_Logic = artifacts.require("Application_Logic_Contract");
const Access_Validator = artifacts.require("Access_Validator_Contract");
const VPR_Registry = artifacts.require("VPR_Registry_Contract");
const Registration_Validator= artifacts.require("Registration_Validator_Contract")
const VSC = artifacts.require("Verifier"); 


//const Registration Validator = artifacts.require("Registration_Validator_Contract");

module.exports = async function(deployer, network, accounts) {
    await deployer.deploy(VPR_Registry); 

    await deployer.deploy(Policy_Storage);
    const deployedPolicyStorage = await Policy_Storage.deployed();

    await deployer.deploy(Attribute_Storage);
    const deployedAttributeStorage = await Attribute_Storage.deployed();

    await deployer.deploy(Application_Logic, ["Alice", "Bob", "Charlie"]);
    const deployedApplicationLogic = await Application_Logic.deployed();

    await deployer.deploy(Access_Validator, deployedPolicyStorage.address, deployedAttributeStorage.address, deployedApplicationLogic.address);
    const deployedAccessValidator = await Application_Logic.deployed();

    

    await deployedApplicationLogic.setAccessValidatorContract(deployedAccessValidator.address);

    await deployer.deploy(VSC);
    const deployedVSC = await VSC.deployed();

    await deployer.deploy(Registration_Validator);
    const deployedRegistrationValidator = await Registration_Validator.deployed();





};


