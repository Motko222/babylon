o#!/bin/bash

if [ -f ~/scripts/babylon/config/env ]
 then
   echo "Config file found."
 else
   read -p "Wallet name? " WALLET
   read -p "Moniker name? " MONIKER
   echo "WALLET="$WALLET > ~/scripts/babylon/config/env
   echo "MONIKER="$MONIKER >> ~/scripts/babylon/config/env
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
curl -Ls https://go.dev/dl/go1.22.0.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
eval $(echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee /etc/profile.d/golang.sh)
eval $(echo 'export PATH=$PATH:$HOME/go/bin' | tee -a $HOME/.profile)
go version

# Download and build binaries
# Clone project repository
cd $HOME
rm -rf babylon
git clone https://github.com/babylonchain/babylon.git
cd babylon
git checkout v0.8.3
make build

# Prepare binaries for Cosmovisor
mkdir -p $HOME/.babylond/cosmovisor/genesis/bin
mv build/babylond $HOME/.babylond/cosmovisor/genesis/bin/
rm -rf build

# Create application symlinks
sudo ln -s $HOME/.babylond/cosmovisor/genesis $HOME/.babylond/cosmovisor/current -f
sudo ln -s $HOME/.babylond/cosmovisor/current/bin/babylond /usr/local/bin/babylond -f

# Install Cosmovisor and create a service
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.5.0



# Initialize the node
babylond init $MONIKER --chain-id $NETWORK

# Set node configuration
sed -i -e 's/^chain-id =.*/chain-id = "bbn-test-3"/' $HOME/.babylond/config/client.toml
sed -i -e 's/^keyring-backend =.*/keyring-backend = "test"/' $HOME/.babylond/config/client.toml
sed -i -e 's/26657/17457/' $HOME/.babylond/config/client.toml

# Download genesis and addrbook
wget https://github.com/babylonchain/networks/raw/main/bbn-test-3/genesis.tar.bz2
tar -xjf genesis.tar.bz2
rm genesis.tar.bz2
mv genesis.json ~/.babylond/config/genesis.json

# Add seeds
sed -i -e "s|^seeds *=.*|seeds = \"ade4d8bc8cbe014af6ebdf3cb7b1e9ad36f412c0@testnet-seeds.polkachu.com:20656\"|" $HOME/.babylond/config/config.toml

# Add persistent_peers
peers="3774fb9996de16c2f2280cb2d938db7af88d50be@162.62.52.147:26656,b82b321380d1d949d1eed6da03696b1b2ef987ba@148.251.176.236:3000,1533286ed0213784b8f3b5d3bf2dfba5ac76450a@34.125.207.98:26656,c0ee3e7f140b2de189ce853cfccb9fb2d922eb66@95.217.203.226:26656,e46f38454d4fb889f5bae202350930410a23b986@65.21.205.113:26656,25abb614b96fa606fb5514fcf711635e8e861d8f@217.72.207.107:26656,1ecc4a9d703ad52d16bf30a592597c948c115176@165.154.244.14:26656,868730197ee267db3c772414ec1cd2085cc036d4@148.251.235.130:17656,c3e82156a0e2f3d5373d5c35f7879678f29eaaad@144.76.28.163:46656,82191d0763999d30e3ddf96cc366b78694d8cee1@162.19.169.211:26656,26acaa8356468376abcfbbafb92e45fcb9fb14c7@65.109.64.179:26656,bb60df4fc43fd4915e16a779611e919fda4a57cb@95.216.187.89:26656,73d0b886307757aa7e0778ca272851c1d24c2e7d@135.181.246.250:3400,35abd10cba77f9d2b9b575dfa0c7c8c329bf4da3@104.196.182.128:26656,26cb133489436035829b6920e89105046eccc841@178.63.95.125:26656,2b9433ec17f98c902ce6bf0031342f20fb6e9cf8@80.64.208.1:26656,9d840ebd61005b1b1b1794c0cf11ef253faf9a84@43.157.95.203:26656,10b483d706782dd53834eca77562e081e52b16dd@3.137.160.91:26656,94a6b8d058bc3db464ab8ec0b824cd40c09a2385@3.139.87.123:26656,564af85d70a1f7227146b1840f467015f8e9af5a@141.95.110.70:26656,8f618f4f40d1c27e27b760ca10246b8b113e94be@18.222.121.72:26656,179a498904d880587cc37d07ebd1e01ff81a02fe@3.139.215.161:26656,ce1caddb401d530cc2039b219de07994fc333dcf@162.19.97.200:26656,23c5d32dcdaff8aead85485f984ca21c48ac495c@5.161.123.139:26656,94039e66a22103ce28c85852c594cacabc6decd1@37.27.54.184:27656,a1a0ec58bf2be5ba114a648f84e53e776f5e4902@18.224.58.14:26656,163ba24f7ef8f1a4393d7a12f11f62da4370f494@89.117.57.201:10656,b1783b0d95ffeeac6c81be47ff8552bbc27bc054@18.118.205.156:26656,06ac37a86b250187a68f921dc81d3bd3920f680d@5.104.83.230:26656,11a40047f142b07119b29262da9f7800640b0699@88.217.142.242:16456,ac65cb7c09f9b0f8aaf2605a9cf9d5684cda87d9@3.136.240.237:26656,fad3a0485745a49a6f95a9d61cda0615dcc6beff@89.58.62.213:26501,3bd2dbed00eab2bdf777ecb012ceff403659f8ef@18.171.248.222:26656,be1ff98cfdad3b765d3ef0ebd44ead182a020d23@95.217.35.179:26656,1bdc05708ad36cd25b3696e67ac455b00d480656@37.60.243.219:26656,3f5fcc3c8638f0af476e37658e76984d6025038b@134.209.203.147:26656,7720914dd724043a1cd5950fad726f67e155fb15@88.198.54.190:43656,ddd6f401792e0e35f5a04789d4db7dc386efc499@135.181.182.162:26656,fd837edb83d1ad175041b9a72ae6b0f5874d1df7@3.128.203.88:26656,798836777efb5555cfb940129e2073b44f9117e5@141.94.143.203:55706,21d9dd05fa924cbcdaf501b92b74bf106af29c95@89.58.32.218:25000,8566da036cb96a50b011f7a04eb796748f71a71e@51.89.40.26:26656,90eac330252ff51bf461602e7b8df054ce8583ae@65.109.64.57:26656,d43f2ed7961c199dc304e3e34d03247f0aa0615e@51.158.77.69:26656,424325d33fcc86c1cfc085cf412b105348ac2fcd@65.109.85.221:2050,86e9a68f0fd82d6d711aa20cc2083c836fb8c083@222.106.187.14:56000,5b197ab8f05c0140d622b258f0734a3bb7c4128d@88.198.8.79:2050,326fee158e9e24a208e53f6703c076e1465e739d@193.34.212.39:26659,6f3f691d39876095009c223bf881ccad7bd77c13@176.227.202.20:56756,5463943178cdb57a02d6d20964e4061dfcf0afb4@142.132.154.53:20656,0c9f976c92bcffeab19944b83b056d06ea44e124@5.78.110.19:26656,5b124ed79f5f0c02ffca4bfb8a73469265f46de1@18.190.176.73:26656,a25c37941e272b5ed0ea40e8f39e95c0d9c55083@178.63.105.185:26656,05ec92459362ea3969a8980ec87e64df49cf8826@65.108.236.43:21156,49b4685f16670e784a0fe78f37cd37d56c7aff0e@3.137.187.30:26656,e3b214c693b386d118ea4fd9d56ea0600739d910@65.108.195.152:26656,59df4b3832446cd0f9c369da01f2aa5fe9647248@65.109.97.139:26656,5e02bb2c9a644afae6109bf2c264d356fad27618@15.165.166.210:26656,49b15e202497c231ebe7b2a56bb46cfc60eff78c@135.181.134.151:46656,6990fd085c9e2e8c9256f144799d18df51f74022@141.94.195.144:26656,0ccb869ba63cf7730017c357189d01b20e4eb277@185.84.224.125:20656,9cb1974618ddd541c9a4f4562b842b96ffaf1446@18.119.172.102:26656,b4215706647068b234d8b72da1736b0e460e5cf1@65.21.228.25:26656,f94e9f91f6989df2c4b4e3f540abb039ffdcc7dc@158.220.87.205:26656,5145171795b9929c41374ce02feef8d11228c33b@160.202.128.199:55706,1eb7b2585cf32255abc0371cd07624cba0706e29@103.35.191.186:26656,26240e4061426d22d5594f91f2754a28a80494bc@109.199.96.75:26656,4e893ae5671ac29b90229ec69528f731b5e359bb@36.153.240.230:26656,395af7ddf487e3adb1600adfdf276e9410d2bc39@34.96.157.76:26656,ade4d8bc8cbe014af6ebdf3cb7b1e9ad36f412c0@176.9.82.221:20656"
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
echo "Check https://www.polkachu.com/testnets/babylon/snapshots for latest shanshot height"
read -p "Snapshot height? " snapshot
wget -O babylon_$snapshot.tar.lz4 https://snapshots.polkachu.com/testnet-snapshots/babylon/babylon_$snapshot.tar.lz4 --inet4-only
lz4 -c -d babylon_$snapshot.tar.lz4  | tar -x -C $HOME/.babylond
rm babylon_$snapshot.tar.lz4

#create wallet and bls key
babylond keys add $KEY --recover

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

