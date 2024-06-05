const VPR_Registry_Contract = artifacts.require("VPR_Registry_Contract");

//module.exports = function (deployer) {
  //deployer.deploy(VPR_Registry_Contract);
//};

console.log("Deployment of VPR Registry Contract")

module.exports = function(deployer, network, accounts) {
    console.log('Deploying to network:', network);
    console.log('Deploying from account:', accounts[0]);
  
    deployer.deploy(VPR_Registry_Contract).then(() => {
      console.log('Deployed MyContract to address:', VPR_Registry_Contract.address);
    });
  };