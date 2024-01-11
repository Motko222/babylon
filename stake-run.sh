#!/bin/bash

pkill -f "stake-daemon"
sleep 5s
bash ~/scripts/babylon/stake-daemon.sh >/dev/null &
