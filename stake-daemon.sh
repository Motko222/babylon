#!/bin/bash

while true
do
 echo $(date +'%y-%m-%d %H:%M') >> ~/logs/bbn-stake.txt
 bash ~/scripts/babylon/stake.sh >> ~/logs/bbn-stake.txt
 delay=$(( $RANDOM % 1800 + 1 ))s
 echo "Waiting $delay" >> ~/logs/bbn-stake.txt
 sleep $delay
done
