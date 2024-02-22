#!/bin/bash

source ~/scripts/babylon/config/env

json=$(curl -s localhost:16457/status | jq .result.sync_info)

pid=$(pgrep babylond)
ver=$(babylond version)
network=$(babylond status | jq -r .NodeInfo.network)
type="validator"
foldersize1=$(du -hs ~/.babylond | awk '{print $1}')
foldersize2=$(du -hs ~/babylon | awk '{print $1}')
#logsize=$(du -hs ~/logs/babylon.log | awk '{print $1}')
latestBlock=$(echo $json | jq -r .latest_block_height)
catchingUp=$(echo $json | jq -r .catching_up)
votingPower=$(babylond status 2>&1 | jq -r .ValidatorInfo.VotingPower)
wallet=$(echo $PSWD | babylond keys show $KEY -a)
valoper=$(echo $PSWD | babylond keys show $KEY -a --bech val)
pubkey=$(babylond tendermint show-validator --log_format json | jq -r .key)
#delegators=$(babylond query staking delegations-to $valoper --chain-id $NETWORK -o json | jq '.delegation_responses | length')
#jailed=$(babylond query staking validator $valoper --chain-id $NETWORK -o json | jq -r .jailed)
#tokens=$(babylond query staking validator $valoper --chain-id $NETWORK -o json | jq -r .tokens | awk '{print $1/1000000}')
balance=$(babylond query bank balances $wallet | grep amount | awk '{print $3}' | sed 's/"//g' | awk '{print $1 / 1000000}' )
#bls=$(babylond query txs --events 'message.action=/babylon.checkpointing.v1.MsgAddBlsSig&message.sender='$WALLET --chain-id $NETWORK -o json | jq -r .txs[-1].timestamp)
active=$(babylond query tendermint-validator-set --chain-id $NETWORK | grep -c $pubkey)
threshold=$(babylond query tendermint-validator-set --chain-id $NETWORK -o json | jq -r .validators[].voting_power | tail -1)

if $catchingUp
 then 
  status="warning"
  note="height=$latestBlock"
 else 
  status="ok"
  note="act $active | del $delegators | vp $tokens | thr $threshold | bal $balance | bls $(date -d $bls +'%y-%m-%d %H:%M')"
fi

if [ $jailed == true ]
 then
  status="error"
  note="jailed"
fi 

if [ -z $pid ];
then status="error";
 note="not running";
fi

echo "updated='$(date +'%y-%m-%d %H:%M')'"
echo "version='$ver'"
echo "process='$pid'"
echo "status="$status
echo "note='$note'"
echo "network='$network'"
echo "type="$type
echo "folder1=$foldersize1"
echo "folder2=$foldersize2"
#echo "log=$logsize" 
echo "id=$MONIKER" 
echo "key=$KEY"
echo "wallet=$wallet"
echo "valoper=$valoper"
echo "pubkey=$pubkey"
echo "catchingUp=$catchingUp"
echo "active=$active"
echo "jailed=$jailed"
echo "height=$latestBlock"
echo "votingPower=$votingPower"
echo "threshold=$threshold"
echo "tokens=$tokens"
echo "delegators=$delegators"
echo "balance=$balance"
echo "bls="$bls
