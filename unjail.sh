#!/bin/bash
babylond tx slashing unjail --from $KEY --chain-id $NETWORK --gas-prices 0.1ubbn --gas-adjustment 1.5 --gas auto -y
