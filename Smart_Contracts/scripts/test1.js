// Import required modules
const AttributeStorage = artifacts.require("Attribute_Storage_Contract");

// Define the script
module.exports = async function(callback) {
    try {
        // Deploy the smart contract
        const attributeStorageInstance = await AttributeStorage.deployed();
        
        // Instantiate a user (address)
        const userAddress = "0xceefe3Ef3E922BbC8Fcb97236A7016C582DE0e83"; // Replace with your desired user address
        
        // Call the modifyAttributeStorage function with the instantiated user's address
        const attribute1 = [{ bestandene_value_checks: "lives in Berlin" }]; // Define your attribute
        //const attribute2 = [ "older then21" ]; 
        await attributeStorageInstance.modifyAttributeStorage(userAddress, attribute1, { from: userAddress }); // Assuming you're calling from the first account
        //await attributeStorageInstance.modifyAttributeStorage(userAddress, attribute2, { from: userAddress });
        // Call other functions from your smart contract using the user's address
        const userAttributes = await attributeStorageInstance.getAttributesFromAddress(userAddress);
        console.log("User Attributes:", userAttributes);

        const owner = await attributeStorageInstance.Attribute_Storage(userAddress);
        console.log("Owner:", owner);
        
        // Additional function calls can be made here
        
        // Finish script execution
        callback(null);
    } catch (error) {
        // Handle errors
        console.error("Error:", error);
        callback(error);
    }
};
