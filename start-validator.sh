#!bin/bash

babylond tx checkpointing create-validator \
--amount 1000000ubbn \
--pubkey $(babylond tendermint show-validator) \
--moniker $MONIKER \
--identity "ID" \
--details "DETAILS" \
--website "WEBSITE" \
--chain-id bbn-test-2 \
--commission-rate 0.05 \
--commission-max-rate 0.20 \
--commission-max-change-rate 0.01 \
--min-self-delegation 1 \
--from $WALLET \
--gas-adjustment 1.4 \
--gas auto \
--fees 10ubbn \
-y
