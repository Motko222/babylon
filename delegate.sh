#!/bin/bash
source ~/scripts/babylon/config/env

if [ -z $1 ]
then
 read -p "From wallet ? " wallet
else
 wallet=$1
fi

if [ -z $2 ]
then
 read -p "To valoper (blank to delegate to this valoper) ? " valoper
 if [ -z $valoper ]; then valoper=$(babylond keys show $WALLET --bech val | head -1 | awk '{print $3}'); fi
else
 valoper=$2
fi

if [ -z $3 ]
then
 read -p "Amount  ? " amount
else
 amount=$3
fi

amount=$(( $amount * 1000000 ))ubbn

babylond tx epoching delegate $valoper $amount --from $wallet \
 --chain-id bbn-test-2 --gas-prices 0.1ubbn --gas-adjustment 1.5 --gas auto -y
