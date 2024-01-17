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
delegators=$(babylond query staking delegations-to $VALOPER -o json | jq '.delegation_responses | length')
jailed=$(babylond query staking validator $VALOPER -o json | jq -r .jailed)
tokens=$(babylond query staking validator $VALOPER -o json | jq -r .tokens | awk '{print $1/1000000}')
wallet=$(babylond keys show $WALLET -a)
balance=$(babylond query bank balances $wallet | grep amount | awk '{print $3}' | sed 's/"//g' | awk '{print $1 / 1000000}' )
bls=$(babylond query txs --events 'message.action=/babylon.checkpointing.v1.MsgAddBlsSig&message.sender='$wallet -o json | jq -r .txs[-1].timestamp)

if $catchingUp
 then 
  status="warning"
  note="height=$latestBlock"
 else 
  status="ok"
  note="del $delegators | vp $tokens | bal $balance | bls $(date -d $bls +'%y-%m-%d %H:%M')"
fi

if [ -z $pid ];
then status="error";
 note="not running";
fi

echo "updated="$(date +'%y-%m-%d %H:%M')
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
echo "wallet=$WALLET"
echo "catchingUp=$catchingUp"
echo "jailed=$jailed"
echo "height=$latestBlock"
echo "votingPower=$votingPower"
echo "tokens=$tokens"
echo "delegators=$delegators"
echo "balance=$balance"
echo "bls="$bls
