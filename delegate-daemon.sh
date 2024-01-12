#!/bin/bash
source ~/scripts/babylon/config/env
keys=$(babylond keys list | grep -E 'name' | sed 's/  name: //g' | grep -v master)
rm ~/logs/bbn-stake.txt

for i in $keys
do
   wallet=$(babylond keys show $i -a)
   balance=$(babylond query bank balances $wallet | grep amount | awk '{print $3}' | sed 's/"//g' )

  if [[ $balance -gt 1010000 ]]
     then
      toStake=${balance::-6}
      bash ~/scripts/babylon/delegate.sh $i $VALOPER $toStake #>/dev/null 2>&1
      break
  fi
done

delay=$(( $RANDOM % 1800 + 1800 ))s
echo "$(date +'%y-%m-%d %H:%M') $i staked $toStake" >> ~/logs/bbn-stake.txt
echo "$(date +'%y-%m-%d %H:%M') $i staked $toStake"
sleep $delay




