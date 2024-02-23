#!/bin/bash
source ~/scripts/babylon/config/env

if [ -z $1 ]
then
 read -p "From key (default $KEY) ? " key
 if [ -z $key ]; then key=$KEY; fi
else
 key=$1
fi

if [ -z $2 ]
then
 def_valoper=$(echo $PSWD | $BINARY keys show $KEY -a --bech val)
 read -p "To valoper (default $def_valoper) ? " valoper
 if [ -z $valoper ]; then valoper=$def_valoper; fi
else
 valoper=$2
fi

wallet=$(echo $PSWD | $BINARY keys show $key --output json | jq -r .address)
balance=$(babylond query bank balances $wallet -o json | jq -r .balances[].amount )

if [ -z $3 ]
then
 read -p "Amount (mas $(( balance - 50000 ))ubbn)  ? " amount
else
 amount=$3
fi

amount=$(( amount ))ubbn

echo $PSWD | $BINARY tx epoching delegate $valoper $amount --from $wallet \
 --chain-id $NETWORK --gas $GAS --gas-adjustment $GAS_ADJ --gas-prices $GAS_PRICE -y
