#!/bin/bash

source ~/scripts/babylon/config/env

echo   "---- SUMMARY --------------------------------------------------------------------------"
printf "%-12s %9s %9s %9s\n" Id Balance Delegated Reward
echo   "---------------------------------------------------------------------------------------"

echo $PSWD | babylond keys list | grep -E 'name' | sed 's/  name: //g' >~/scripts/babylon/config/keys

cat ~/scripts/babylon/config/keys | while read line
do
   key=$(echo $line | awk '{print $1}')
   wallet=$(echo $PSWD | babylond keys show $key -a) 
   balance=$(babylond query bank balances $wallet | grep amount | awk '{print $3}' | sed 's/"//g' | awk '{print $1/1000000}')
   valoper=$(echo $PSWD | babylond keys show $KEY --bech val | grep valoper | awk '{print $3}')
   rewards=$(babylond query distribution rewards $wallet $valoper 2>/dev/null \
     | grep amount | awk '{print $3}' | sed 's/"//g' | awk '{print $1/1000000}')

   stake=$(babylond query staking delegation $wallet $valoper 2>/dev/null \
     | grep amount | awk '{print $2}' | sed 's/"//g' | awk '{print $1/1000000}' )

   printf "%-12s %9s %9s %9s\n" \
      $key $balance $stake $rewards
done
