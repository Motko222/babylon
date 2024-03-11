#!/bin/bash

source ~/scripts/babylon/config/env
source ~/.bash_profile

json=$(curl -s localhost:16457/status | jq .result.sync_info)

pid=$(pgrep babylond)
ver=$(babylond version)
chain=$(babylond status | jq -r .NodeInfo.network)
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
delegators=$(babylond query staking delegations-to $valoper --chain-id $NETWORK -o json | jq '.delegation_responses | length')
val_status=$(babylond query staking validator $valoper --chain-id $NETWORK -o json | jq -r .validator.status)
tokens=$(babylond query staking validator $valoper --chain-id $NETWORK -o json | jq -r .validator.tokens | awk '{print $1/1000000}')
balance=$(babylond query bank balances $wallet | grep amount | awk '{print $3}' | sed 's/"//g' | awk '{print $1 / 1000000}' )
#bls=$(babylond query txs --events 'message.action=/babylon.checkpointing.v1.MsgAddBlsSig&message.sender='$WALLET --chain-id $NETWORK -o json | jq -r .txs[-1].timestamp)
active=$(babylond query tendermint-validator-set --chain-id $NETWORK | grep -c $pubkey)
threshold=$(babylond query tendermint-validator-set --chain-id $NETWORK -o json | jq -r .validators[].voting_power | tail -1)
bucket=validator
id=babylon-$BABYLON_ID


if $catchingUp
 then 
  status="syncing"
  note="height=$latestBlock"
 else 
  if [ $val_status -eq 3 ]; then status=active; fi
  if [ $val_status -eq 2 ]; then status=inactive; fi
  if [ $val_status -eq 1 ]; then status=unbonded; fi
 # note="act $active | del $delegators | vp $tokens | thr $threshold | bal $balance | bls $(date -d $bls +'%y-%m-%d %H:%M')"
fi

#if [ $jailed == true ]
# then
#  status="error"
#  note="jailed"
#fi 

if [ -z $pid ];
then status="offline";
 note="process not running";
fi

echo "updated='$(date +'%y-%m-%d %H:%M')'"
echo "version='$ver'"
echo "process='$pid'"
echo "status="$status
echo "note='$note'"
echo "chain='$chain'"
echo "type="$type
echo "folder1=$foldersize1"
echo "folder2=$foldersize2"
#echo "log=$logsize" 
echo "id=$id"
echo "moniker=$MONIKER" 
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
echo "val_status="$val_status

# send data to influxdb
if [ ! -z $INFLUX_HOST ]
then
 curl --request POST \
 "$INFLUX_HOST/api/v2/write?org=$INFLUX_ORG&bucket=$bucket&precision=ns" \
  --header "Authorization: Token $INFLUX_TOKEN" \
  --header "Content-Type: text/plain; charset=utf-8" \
  --header "Accept: application/json" \
  --data-binary "
    status,machine=$MACHINE,id=$id,moniker=$MONIKER status=\"$status\",message=\"$message\",version=\"$version\",url=\"$url\",chain=\"$chain\",votingPower=\"$votingPower\",threshold=\"$threshold\",active=\"$active\",jailed=\"$jailed\" $(date +%s%N) 
    "
fi
