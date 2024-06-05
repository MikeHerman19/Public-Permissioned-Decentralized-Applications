pragma solidity ^0.8.0;

struct G1Point {
        uint X;
        uint Y;
    }

    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }

    struct Proof {
        G1Point a;
        G2Point b;
        G1Point c;
    }

interface IAttributeStorage {
    function modifyAttributeStorage(address _subject, uint[] memory _inputs) external;
}

interface IVerifier {
    function verifyTx(Proof memory proof, uint[56] memory input) external view returns (bool);
}






contract Registration_Validator_Contract{

    address public owner; 

    //address public VSC;

    IAttributeStorage public attributeStorage;
    //IVerifier public vsc; 

    mapping(uint => address) private VSCregistry; 
    mapping(address => uint[]) private ValueChecks; 

    // elliptic curve points for proof verification
    

    constructor( address _attributeStorageContractAddress, address _VSCContractAddress, uint[] memory _valuechecks) {
        owner = msg.sender;
        VSCregistry[1] = _VSCContractAddress ;
        ValueChecks[_VSCContractAddress] = _valuechecks; 
        attributeStorage = IAttributeStorage(_attributeStorageContractAddress);

        //vsc = IVerifier(_VSCContractAddress); 
    }

    function registerVSC(uint VSCid, address contractAddress, uint[] memory _valuechecks) public {
        require(contractAddress != address(0), "Invalid address");
        require(msg.sender == owner, "Only Owner is allowed to call that function");
        VSCregistry[VSCid] = contractAddress;
        ValueChecks[contractAddress] = _valuechecks; 
    }

    function registration(Proof memory _proof, uint[56] memory input, uint _idVSC) public returns(bool){
        IVerifier instance = IVerifier(VSCregistry[_idVSC]);
        bool verification = instance.verifyTx(_proof, input);
        //bool verification = vsc.verifyTx(_proof, input);
        if(verification == true){
            attributeStorage.modifyAttributeStorage(msg.sender, ValueChecks[VSCregistry[_idVSC]]); 
        }
        return verification; 

    }

    

}
