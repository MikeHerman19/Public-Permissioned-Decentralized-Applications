#!/bin/bash

# Compile contracts
echo "Compiling contracts..."
truffle compile

# Deploy contracts to the desired network
echo "Deploying contracts..."
truffle migrate --network <network_name>

# Execute test script
echo "Executing test script..."
truffle exec test1.js --network development
