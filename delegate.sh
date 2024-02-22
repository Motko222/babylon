#!/bin/bash
source ~/scripts/babylon/config/env

if [ -z $1 ]
then
 read -p "From key (default $KEY) ? " key
 if [ -z $key ]; then key=$KEY; fi
else
 key=$1
fi

wallet=$(babylond keys show $key --output json | jq -r .address)
balance=$(babylond query bank balances $wallet -o json | jq -r .balances[].amount | awk '{print $1/1000000}')
echo "Balance: $balance bbn"

if [ -z $2 ]
then
 def_valoper=$(echo $PWD | $BINARY keys show $key -a --bech val)
 read -p "To valoper (default $def_valoper) ? " valoper
 if [ -z $valoper ]; then valoper=$def_valoper; fi
else
 valoper=$2
fi

if [ -z $3 ]
then
 read -p "Amount (bbn)  ? " amount
else
 amount=$3
fi

amount=$(( $amount * 1000000 ))ubbn

echo $PSWD | $BINARY tx epoching delegate $valoper $amount --from $wallet \
 --chain-id $NETWORK --gas-prices 0.1ubbn --gas-adjustment 1.5 --gas auto -y | tail -1
