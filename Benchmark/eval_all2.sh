#!/bin/bash

export PATH=$PATH:/home/$USER/.zokrates/bin  #for windows we have to use /home and not /USERS as it is stated in the zokrates doc

DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

#declare -a useCases=("DeFi" "Voting" "Marketplace")
declare -a useCases=("Marketplace")
#declare -a anzahl=("1" "2" "4" "6" "8")
declare -a anzahl=("2" "4" "6" "8")
#declare -a anzahl=("8")

for useCase in "${useCases[@]}"
do 

	mkdir $DIR/$useCase/results 2> /dev/null
	RESULT="$DIR/$useCase/results/result.txt"

	if [ ! -f "$RESULT" ] 
	then
		echo "useCase,value_checks, timestamp,gas_call,witness_s,setup_s,proof_s,compiled_size,proving_key_size,verification_key_size, constraints" > $RESULT
	else
		rm -f "$DIR/results/result.txt"
		echo "useCase,value_checks, timestamp,gas_call,witness_s,setup_s,proof_s,compiled_size,proving_key_size,verification_key_size, constraints" > $RESULT
	fi

	for anz in "${anzahl[@]}"
	do

		echo "Start $useCase Anzahl: $anz"
		mkdir $DIR/$useCase/$anz/results 2> /dev/null
		echo "Start Attestation"
		# Attestation

		cd $DIR/$useCase/$anz/attestation
		python3.9 -m virtualenv venv
		source venv/bin/activate
		echo "Install requirements"
		python3.9 -m pip install -r requirements.txt

		echo "run attestation script"
		python3.9 attestation.py > $DIR/$useCase/$anz/artifacts/witness-parameters.txt

		# Proving
		echo "Start Proving"
		cd $DIR/$useCase/$anz/proving
		echo "ZoKrates compile"
		$DIR/monitor2.sh zokrates compile -i verify.zok -o $DIR/$useCase/$anz/artifacts/out $DIR/$useCase/$anz/results/compilation1.txt > $DIR/$useCase/$anz/results/constraints.txt
		compiledSize=$(du -kh $DIR/$useCase/$anz/artifacts/out | cut -f1)
		constraints=$(cat $DIR/$useCase/$anz/results/constraints.txt | cut -f1 | grep "constraints:" | awk '{print $4}' | xargs)

		START=`date +%s`
		witnesses=$(cat $DIR/$useCase/$anz/artifacts/witness-parameters.txt)
		echo "ZoKrates compute witness"
		#zokrates compute-witness -i $DIR/$useCase/$anz/artifacts/out -o $DIR/$useCase/$anz/artifacts/witness -a $witnesses
		$DIR/monitor2.sh zokrates compute-witness -i $DIR/$useCase/$anz/artifacts/out -o $DIR/$useCase/$anz/artifacts/witness -a $witnesses $DIR/$useCase/$anz/results/witness1.txt
		END=`date +%s`
		witnessDur=$(echo "$END - $START" | bc)

		mv abi.json $DIR/$useCase/$anz/artifacts/

		# Zokrates setup
		echo "Start Setup"

		START=`date +%s`
		$DIR/monitor2.sh zokrates setup -i $DIR/$useCase/$anz/artifacts/out -p $DIR/$useCase/$anz/artifacts/proving.key -v $DIR/$useCase/$anz/artifacts/verification.key $DIR/$useCase/$anz/results/setup1.txt
		#zokrates setup -i $DIR/$useCase/$anz/artifacts/out -p $DIR/$useCase/$anz/artifacts/proving.key -v $DIR/$useCase/$anz/artifacts/verification.key
		END=`date +%s`
		setupDur=$(echo "$END - $START" | bc)
		provingKeySize=$(du -kh $DIR/$useCase/$anz/artifacts/proving.key  | cut -f1)
		verificationKeySize=$(du -kh $DIR/$useCase/$anz/artifacts/verification.key | cut -f1)

		# Verification
		echo "Start Verification"
		zokrates export-verifier -i $DIR/$useCase/$anz/artifacts/verification.key -o $DIR/$useCase/$anz/verification/contracts/Verifier.sol
		verifier_size=$(du -kh $DIR/$useCase/$anz/verification/contracts/verifier.sol | cut -f1 | sed 's/\([0-9]\),/\1./g' | xargs)
		
		START=`date +%s`
		$DIR/monitor2.sh zokrates generate-proof -i $DIR/$useCase/$anz/artifacts/out -j $DIR/$useCase/$anz/artifacts/proof.json -p $DIR/$useCase/$anz/artifacts/proving.key -w $DIR/$useCase/$anz/artifacts/witness $DIR/$useCase/$anz/results/proof1.txt
		#zokrates generate-proof -i $DIR/$useCase/$anz/artifacts/out -j $DIR/$useCase/$anz/artifacts/proof.json -p $DIR/$useCase/$anz/artifacts/proving.key -w $DIR/$useCase/$anz/artifacts/witness
		END=`date +%s`
		proofDur=$(echo "$END - $START" | bc)

		# Test
		cd $DIR/$useCase/$anz/verification
		truffle test > $DIR/$useCase/$anz/results/verification.txt
		gas_used=$(grep "Gas used:" $DIR/$useCase/$anz/results/verification.txt | awk '{print $3}')
		echo $gas_used

		# Statistics
		echo "Witness: $witnessDur sec."
		echo "Setup: $setupDur sec."
		echo "Proof: $proofDur sec."
		echo "Compiled size: $compiledSize"
		echo "Proving key size: $provingKeySize"
		echo "Verification key size: $verificationKeySize"
		
		#"useCase,value_checks, timestamp,gas_call,witness_s,setup_s,proof_s,compiled_size,proving_key_size,verification_key_size, constraints"
		row="$useCase,$anz,$(date +%s), $gas_used, $witnessDur, $setupDur, $proofDur, $compiledSize, $provingKeySize, $verificationKeySize, $constraints"
		echo $row >> $RESULT 

		#cd $ALL_DIR/$proof
		#echo "Eval: $proof"
		#$ALL_DIR/$proof/eval.sh > $ALL_DIR/eval/$proof.txt

		#cd $ALL_DIR/eval
		#gas_call=$(cat $ALL_DIR/eval/$proof.txt | grep "Gas used: " | sed "s/^.*[^0-9] //")
		#witness_s=$(cat $ALL_DIR/eval/$proof.txt | grep "Witness: " | sed "s/^.*[^0-9] //")
		#setup_s=$(cat $ALL_DIR/eval/$proof.txt | grep "Setup: " | sed "s/^.*[^0-9] //")
		#proof_s=$(cat $ALL_DIR/eval/$proof.txt | grep "Proof: " | sed "s/^.*[^0-9] //")
		#compiled_size=$(cat $ALL_DIR/eval/$proof.txt | grep "Compiled size: " | sed "s/^.*[^0-9] //")
		#proving_key_size=$(cat $ALL_DIR/eval/$proof.txt | grep "Proving key size: " | sed "s/^.*[^0-9] //")
		#verification_key_size=$(cat $ALL_DIR/eval/$proof.txt | grep "Verification key size: " | sed "s/^.*[^0-9] //")

		#row="$proof,$(date +%s),$gas_call,$witness_s,$setup_s,$proof_s,$compiled_size,$proving_key_size,$verification_key_size"

		#echo $row >> $ALL_EVALS
		
		#echo $row
		echo $row
		echo "sleep for 5 sec"
		sleep 5
	done
	sleep 5 
done