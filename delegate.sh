#!/bin/bash
source ~/scripts/babylon/config/env

if [ -z $1 ]
then
 read -p "From wallet ? " wallet
else
 fromWallet=$1
fi

if [ -z $2 ]
then
 read -p "To valoper ? " valoper
else
 toValoper=$2
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
