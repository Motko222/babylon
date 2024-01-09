#!/bin/bash

curl -s localhost:26657/status | jq .result.sync_info
