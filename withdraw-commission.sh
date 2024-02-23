#!/bin/bash

FOLDER=$(echo $(cd -- $(dirname -- "${BASH_SOURCE[0]}") && pwd) | awk -F/ '{print $NF}')
source ~/scripts/$FOLDER/config/env

valoper=$(echo $PSWD | $BINARY keys show $KEY -a --bech val)

echo $PSWD | babylond tx distribution withdraw-rewards $valoper \
  --chain-id $NETWORK --from $KEY --commission --gas $GAS --gas-adjustment $GAS_ADJ --gas-prices $GAS_PRICE -y

