#!/bin/bash

source ~/scripts/babylon/config/env

if [ -z $1 ]
then
 read -p "From wallet ? " from
else
 wallet=$1
fi

if [ -z $2 ]
then
 read -p "To wallet ? " to
else
 valoper=$2
fi

if [ -z $3 ]
then
 read -p "Amount ? " amount
else
 amount=$3
fi

amount=$(( $amount * 1000000 ))ubbn

babylond tx bank send $from $to $amount \
   --gas-prices 0.1ubbn --gas-adjustment 1.5 --gas auto -y
