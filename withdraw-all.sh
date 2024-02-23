#!/bin/bash

FOLDER=$(echo $(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) | awk -F/ '{print $NF}')
source ~/scripts/$FOLDER/config/env

if [ -z $1 ]
then
 read -p "From key (default $KEY) ? " key
 if [ -z $key ]; then key=$KEY; fi
else
 key=$1
fi

echo $PSWD | $BINARY tx distribution withdraw-all-rewards \
  --chain-id $NETWORK --from $key --gas $GAS --gas-adjustment $GAS_ADJ --gas-prices $GAS_PRICE -y
