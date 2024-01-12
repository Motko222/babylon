#!/bin/bash

source ~/scripts/babylon/config/env

json=$(curl -s localhost:16457/status | jq .result.sync_info)

now=$(date +'%y-%m-%d %H:%M')
pid=$(pgrep babylond)
ver=$(babylond version)
foldersize1=$(du -hs ~/.babylond | awk '{print $1}')
foldersize2=$(du -hs ~/babylon | awk '{print $1}')
#logsize=$(du -hs ~/logs/babylon.log | awk '{print $1}')
latestBlock=$(echo $json | jq .latest_block_height | sed 's/"//g' )
catchingUp=$(echo $json | jq .catching_up)
votingPower=$(babylond status 2>&1 | jq .ValidatorInfo.VotingPower | sed 's/"//g')
delegators=$(babylond query staking delegations-to $VALOPER -o json \
  | jq .delegation_responses[].balance.amount | sed 's/"//g' | wc -l )
jailed=$(babylond query staking validator $VALOPER -o json | jq .jailed)
tokens=$(babylond query staking validator $VALOPER -o json | jq .tokens | sed 's/"//g' | awk '{print $1/1000000}')

if $catchingUp
 then 
  status="warning"
  note="height=$latestBlock"
 else 
  status="ok"
  note="$delegators delegators, $tokens bbn"
fi

if [ -z $pid ];
then status="error";
 note="not running";
fi

echo "updated='$now'"
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
