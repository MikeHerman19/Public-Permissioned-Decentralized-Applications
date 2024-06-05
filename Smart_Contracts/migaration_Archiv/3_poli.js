// Migrationsskript in Truffle
const AccessPolicy = artifacts.require("Policy_Storage");
const AnotherContract = artifacts.require("Test_Contract");

module.exports = async function(deployer, network, accounts) {
    await deployer.deploy(AccessPolicy);
    const deployedPolicy = await AccessPolicy.deployed();

    // Übergeben der AccessPolicy Adresse an den Constructor von AnotherContract
    await deployer.deploy(AnotherContract, deployedPolicy.address);
};