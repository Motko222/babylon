#!/bin/bash

while true
do
 echo "Daemon started: "$(date +'%y-%m-%d %H:%M') >> ~/logs/bbn-stake.txt
 bash ~/scripts/babylon/stake-all.sh >> ~/logs/bbn-stake.txt
 delay=$(( $RANDOM % 1800 ))s
 echo "Waiting for next execution $delay" >> ~/logs/bbn-stake.txt
 sleep $delay
done
