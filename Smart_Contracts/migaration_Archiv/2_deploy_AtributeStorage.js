const Attribute_Storage_Contract = artifacts.require("Attribute_Storage_Contract");

//module.exports = function (deployer) {
  //deployer.deploy(VPR_Registry_Contract);
//};

console.log("Deployment of Attribute Storage")

module.exports = function(deployer, network, accounts) {
    console.log('Deploying to network:', network);
    console.log('Deploying from account:', accounts[0]);
    console.log(accounts)
  
    deployer.deploy(Attribute_Storage_Contract).then(() => {
      console.log('Deployed MyContract to address:', Attribute_Storage_Contract.address);
    });
  };