#!/bin/bash

while true
do
 echo "Daemon started: "$(date +'%y-%m-%d %H:%M') >> ~/logs/bbn-stake.txt
 bash ~/scripts/babylon/stake.sh >> ~/logs/bbn-stake.txt
 #delay=$(( $RANDOM % 3600 + 3600 ))s
 #echo "Waiting for next execution $delay" >> ~/logs/bbn-stake.txt
 #sleep $delay
done
