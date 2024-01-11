#!/bin/bash

if [ -f ~/scripts/babylon/config/env ]
 then
   echo "Config file found."
 else
   read -p "Wallet name? " WALLET
   read -p "Moniker name? " MONIKER
   echo "WALLET="$WALLET >> ~/scripts/babylon/config/env
   echo "MONIKER="$MONIKER > ~/scripts/babylon/config/env
   echo "Config file created."
fi

# UPDATE SYSTEM AND INSTALL BUILD TOOLS
sudo apt -q update
sudo apt -qy install curl git jq lz4 build-essential
sudo apt -qy upgrade
sudo apt-get install make
sudo apt-get install lz4
sudo apt-get install jq

# INSTALL GO
sudo rm -rf /usr/local/go
curl -Ls https://go.dev/dl/go1.20.12.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
eval $(echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh)
eval $(echo 'export PATH=$PATH:$HOME/go/bin' | tee -a $HOME/.profile)
go version

# Download and build binaries
# Clone project repository
cd $HOME
rm -rf babylon
git clone https://github.com/babylonchain/babylon.git
cd babylon
git checkout v0.7.2

# Build binaries
make build

# Prepare binaries for Cosmovisor
mkdir -p $HOME/.babylond/cosmovisor/genesis/bin
mv build/babylond $HOME/.babylond/cosmovisor/genesis/bin/
rm -rf build

# Create application symlinks
sudo ln -s $HOME/.babylond/cosmovisor/genesis $HOME/.babylond/cosmovisor/current -f
sudo ln -s $HOME/.babylond/cosmovisor/current/bin/babylond /usr/local/bin/babylond -f

# Install Cosmovisor and create a service
# Download and install Cosmovisor
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.5.0

# Set node configuration
babylond config chain-id bbn-test-2
babylond config keyring-backend test
babylond config node tcp://localhost:16457

# Initialize the node
babylond init $MONIKER --chain-id bbn-test-2

# Download genesis and addrbook
curl -Ls https://snapshots.kjnodes.com/babylon-testnet/genesis.json > $HOME/.babylond/config/genesis.json
curl -Ls https://snapshots.kjnodes.com/babylon-testnet/addrbook.json > $HOME/.babylond/config/addrbook.json

# Add seeds
sed -i -e "s|^seeds *=.*|seeds = \"3f472746f46493309650e5a033076689996c8881@babylon-testnet.rpc.kjnodes.com:16459\"|" $HOME/.babylond/config/config.toml

# Add persistent_peers
peers="3287ddbe454cfb5a162799b468c1405b7370c541@95.217.199.12:26601,d5519e378247dfb61dfe90652d1fe3e2b3005a5b@65.109.68.190:16456,cf34c3413b515e0043a279e6085b95e153c50871@168.119.10.134:26656,6f55a3138d18e8c0eaa66e347794428db698bf2a@148.251.176.236:2000,895522d0a1d174b7810f0c4904261f6f014fb193@161.97.123.214:16456,b6300c3bf3a9fa9492c1c7e970265e9dad8d2929@95.216.244.226:16456,0de44b3d4380004838d38797a1aee10392b68420@3.142.201.103:26656,2d7f98f9080467d1d084c6ecfeffc2275de3c3e0@38.242.239.210:16456,9eea44710677f6bca53a30cd5070fb6820b38a77@161.97.114.31:16456,d98fd2665253fc469d861752277ae4732029ca4a@178.18.254.152:16456,aa0756ebb34536d4cee93683ebe135e9704e907d@208.93.66.43:16456,97619188659de26559231d93d7e27be6e58133b7@185.215.166.212:16456,357aedc0f46a7f69f6112099dd135e425c745add@31.220.74.5:16456,f3e39d6d0f3baccc9a46dd9558c171af2070baeb@78.196.234.246:26656,ac4ce172df2d437f63152dd7a8c026a5e283aa19@65.109.175.84:16456,1dd53ef6e8b5290cc766236d56ebe308ff27356f@185.230.138.85:16456,77166640af158920a87186725ecea40b4310e14d@5.189.173.161:16456,bbf8ef70a32c3248a30ab10b2bff399e73c6e03c@65.21.198.100:21756,c78bfc22b8fe6a913520228b75078554758e4b41@185.202.238.243:16456,b32c6ac95268080ec1f336b57a7cab07e7b6f407@38.242.243.17:16456,f2037faa4fab89441b91a87fa81b1fcabfaa77ac@161.97.100.158:16456,0a0d7d245ea67cfeec7d000085260fbe695544f4@207.180.251.220:11656"
sed -i -e "s|^persistent_peers *=.*|persistent_peers = \"$peers\"|" $HOME/.babylond/config/config.toml

# Set minimum gas price
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.00001ubbn\"|" $HOME/.babylond/config/app.toml

# Set pruning
sed -i \
  -e 's|^pruning *=.*|pruning = "custom"|' \
  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
  -e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
  -e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
  $HOME/.babylond/config/app.toml

# Set custom ports
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:16458\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:16457\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:16460\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:16456\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":16466\"%" $HOME/.babylond/config/config.toml
sed -i -e "s%^address = \"tcp://localhost:1317\"%address = \"tcp://0.0.0.0:16417\"%; s%^address = \":8080\"%address = \":16480\"%; s%^address = \"localhost:9090\"%address = \"0.0.0.0:16490\"%; s%^address = \"localhost:9091\"%address = \"0.0.0.0:16491\"%; s%:8545%:16445%; s%:8546%:16446%; s%:6065%:16465%" $HOME/.babylond/config/app.toml

# Download latest chain snapshot
curl -L https://snapshots.kjnodes.com/babylon-testnet/snapshot_latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.babylond
[[ -f $HOME/.babylond/data/upgrade-info.json ]] && cp $HOME/.babylond/data/upgrade-info.json $HOME/.babylond/cosmovisor/genesis/upgrade-info.json

babylond keys add $WALLET
babylond create-bls-key $(babylond keys show $WALLET -a)

#create service
sudo tee /etc/systemd/system/babylon.service > /dev/null << EOF
[Unit]
Description=babylon node service
After=network-online.target

[Service]
User=root
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=/root/.babylond"
Environment="DAEMON_NAME=babylond"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.babylond/cosmovisor/current/bin"

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable babylon.service

echo "Installation done, service is not started. Please run it with start-service.sh."

