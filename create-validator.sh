#!/bin/bash

source ~/scripts/babylon/config/env

echo $PSWD | babylond tx checkpointing create-validator /root/scripts/babylon/validator.json \
--from $KEY --gas-adjustment $GAS_ADJ --gas $GAS --fees 10ubbn -y
