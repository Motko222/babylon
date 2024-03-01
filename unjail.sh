#!/bin/bash
source ~/scripts/babylon/config/env
echo $PSWD | $BINARY tx slashing unjail --from $KEY \
  --chain-id $NETWORK --gas-prices $GAS_PRICE --gas-adjustment $GAS_ADJ --gas $GAS -y
