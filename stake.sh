#!/bin/bash
echo "Staking ended: "$(date +'%y-%m-%d %H:%M') >>~/logs/bbn-stake.txt
source ~/scripts/babylon/config/env

babylond keys list | grep -E 'name|address' | sed 's/- address: //g' | sed 's/  name: //g' | paste - - | grep -v master >~/scripts/babylon/config/keys

cat ~/scripts/babylon/config/keys | while read line
do
   id=$(echo $line | awk '{print $2}')
   wallet=$(echo $line | awk '{print $1}')
   balance=$(babylond query bank balances $wallet | grep amount | awk '{print $3}' | sed 's/"//g' )
   valoper=$(babylond keys show $WALLET --bech val | grep valoper | awk '{print $3}')

  if [[ $balance -gt 1010000 ]]
     then
      toStake=${balance::-6}000000ubbn
      echo $id staked $toStake >>~/logs/bbn-stake.txt
      babylond tx epoching delegate $valoper $toStake --from $wallet \
         --chain-id bbn-test-2 --gas-prices 0.1ubbn --gas-adjustment 1.5 --gas auto -y >/dev/null 2>&1
#     else
#      echo "$id did not stake, balance is $balance"
  fi
  delay=$(( $RANDOM % 300 + 1 ))s
  echo "Waiting $delay" >>~/logs/bbn-stake.txt
  sleep $delay
done
echo "Staking ended: "$(date +'%y-%m-%d %H:%M') >>~/logs/bbn-stake.txt
