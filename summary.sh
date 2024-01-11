#!/bin/bash

source ~/scripts/babylon/config/env

echo   "---- SUMMARY --------------------------------------------------------------------------"
printf "%-12s %9s %9s %9s\n" Id Balance Delegated Reward
echo   "---------------------------------------------------------------------------------------"

babylond keys list | grep -E 'name|address' | sed 's/- address: //g' | sed 's/  name: //g' | paste - - | grep -v master >~/scripts/babylon/config/keys

cat ~/scripts/babylon/config/keys | while read line
do
   id=$(echo $line | awk '{print $2}')
   wallet=$(echo $line | awk '{print $1}')
   balance=$(babylond query bank balances $wallet | grep amount | awk '{print $3}' | sed 's/"//g' | awk '{print $1/1000000}')
   valoper=$(babylond keys show $WALLET --bech val | grep valoper | awk '{print $3}')
   rewards=$(babylond query distribution rewards $wallet $valoper 2>/dev/null \
     | grep amount | awk '{print $3}' | sed 's/"//g' | awk '{print $1/1000000}')
   
   stake=$(babylond query staking delegation $wallet $valoper 2>/dev/null \
     | grep amount | awk '{print $2}' | sed 's/"//g' | awk '{print $1/1000000}' )

   printf "%-12s %9s %9s %9s\n" \
      $id $balance $stake $rewards
done
