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
balance=$(babylond query bank balances $wallet -o json | jq -r .amount | awk '{print $1/1000000}')
echo "Balance: $balance bbn"

if [ -z $2 ]
then
 read -p "To valoper (default $VALOPER) ? " valoper
 if [ -z $valoper ]; then valoper=$VALOPER; fi
else
 valoper=$2
fi

if [ -z $3 ]
then
 read -p "Amount (pryzm)  ? " amount
else
 amount=$3
fi

amount=$(( $amount * 1000000 ))ubbn

babylond tx epoching delegate $valoper $amount --from $wallet \
 --chain-id bbn-test-2 --gas-prices 0.1ubbn --gas-adjustment 1.5 --gas auto -y
