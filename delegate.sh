#!/bin/bash
source ~/scripts/babylon/config/env

babylond keys list | grep -E 'name|address' | sed 's/- address: //g' | sed 's/  name: //g' | paste - - | grep -v master >~/logs/bbn-keys
valoper=$(babylond keys show $WALLET --bech val | grep valoper | awk '{print $3}')

echo WALLETS

cat ~/logs/bbn-keys | while read line
do
   id=$(echo $line | awk '{print $2}')
   wallet=$(echo $line | awk '{print $1}')
   balance=$(babylond query bank balances $wallet | grep amount | awk '{print $3}' | sed 's/"//g' )

   printf "%-12s %-45s %12s/n" $id $wallet $balance

done

echo
read -p "Wallet ? " fromWallet
read -p "Valoper (blank=current)? " toValoper
if [ -z $toValoper ]; then toValoper=$valoper; fi
read -p "Amount (ubbn)? " toStake

babylond tx epoching delegate $toValoper $toStake --from $fromWallet \
 --chain-id bbn-test-2 --gas-prices 0.1ubbn --gas-adjustment 1.5 --gas auto -y 
