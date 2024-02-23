#!/bin/bash

source ~/scripts/babylon/config/env

babylond tx checkpointing create-validator /root/scripts/babylon/validator.json \
--from $KEY --gas-adjustment 1.4 --gas auto --fees 10ubbn -y
