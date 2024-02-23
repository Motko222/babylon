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
 read -p "To wallet ? " to
else
 to=$2
fi

wallet=$(echo $PSWD | $BINARY keys show $key --output json | jq -r .address)
balance=$(babylond query bank balances $wallet -o json | jq -r .balances[].amount )

if [ -z $3 ]
then
 read -p "Amount (max $(( balance - 50000))ubbn) ? " amount
else
 amount=$3
fi

amount=$((amount))ubbn

echo $PSWD | babylond tx bank send $key $to $amount \
   --chain-id $NETWORK --gas-prices 0.1ubbn --gas-adjustment 1.5 --gas auto -y












