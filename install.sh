!#/bin/bash

cd ~
wget -O babylon.sh https://node101.io/testnet/babylon.sh
chmod +x babylon.sh
./babylon.sh

if [ -f ~/scripts/babylon/config/env ]
 then
  read -p "Wallet name? " WALLET
  read -p "Moniker? " MONIKER
  echo "WALLET="$WALLET >> ~/scripts/babylon/config/env
  echo "MONIKER="$MONIKER > ~/scripts/babylon/config/env
fi

babylond keys add $WALLET
babylond create-bls-key $(babylond keys show $WALLET -a)

echo "Done."

