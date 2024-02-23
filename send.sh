#!/bin/bash

source ~/scripts/babylon/config/env

if [ -z $1 ]
then
 read -p "From key ? " from
else
 from=$1
fi

wallet=$(echo $PSWD | $BINARY keys show $key --output json | jq -r .address)
balance=$(babylond query bank balances $wallet -o json | jq -r .balances[].amount | awk '{print $1/1000000}')
echo "Balance: $balance bbn"

if [ -z $2 ]
then
 read -p "To wallet ? " to
else
 to=$2
fi

if [ -z $3 ]
then
 read -p "Amount (bbn) ? " amount
else
 amount=$3
fi

amount=$(echo $amount | awk '{print  $1 * 1000000}' )ubbn

babylond tx bank send $from $to $amount \
   --gas-prices 0.1ubbn --gas-adjustment 1.5 --gas auto -y












