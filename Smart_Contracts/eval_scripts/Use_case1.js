console.log(`Deploying...`)


const gas_limit = 200000000

let accounts = await web3.eth.getAccounts()
let attribute_manager = accounts[0]
let subject = accounts[1]
let resource_owner = accounts[2]



        //gas = await policyArtifact.new.estimateGas({from: resource_owner})
        //smart_policy = await policyArtifact.new({from: resource_owner})

console.log(`Evaluating...`)
        tx = await smart_policy.evaluate(subject, proofs, {gas: gas_limit})
    
        console.log("\tDeployment cost: " + gas)
        console.log("\tEvaluation cost: " + tx.receipt.gasUsed)

        deploycost += `${s},${gas}\n`
        evaluatecost += `${s},${tx.receipt.gasUsed}\n`
    

    fs.writeFileSync(`modularDeployCost.csv`, deploycost)
    fs.writeFileSync(`modularEvaluateCost.csv`, evaluatecost)
        
    callback();