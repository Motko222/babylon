#!/bin/bash

source ~/scripts/babylon/config/env

awk -F “text” '{print $NF}'

json=$(curl -s localhost:16457/status | jq .result.sync_info)

now=$(date +'%y-%m-%d %H:%M')
pid=$(pgrep babylond)
version=$(cat babylon.log | grep "ABCI Handshake App Info" | awk -F "software-version=" '{print $NF}')
foldersize1=$(du -hs ~/.babylond | awk '{print $1}')
foldersize2=$(du -hs ~/babylon | awk '{print $1}')
logsize=$(du -hs ~/logs/babylon.log | awk '{print $1}')
latestBlock=$(echo $json | jq .latest_block_height | sed 's/"//g' )
catchingUp=$(echo $json | jq .catching_up)

if [ catchingUp ]
 then 
  status="warning"
  note="height=$latestBlock"
 else 
  status="ok"
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
echo "log=$logsize" 
echo "id=$MONIKER" 
echo "wallet=$WALLET"
echo "catchingUp=$catchingUp"
echo "height=$latestBlock"
