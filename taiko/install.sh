#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
echo "Устанавливаем переменные"
echo "-----------------------------------------------------------------------------"
# Удаление старых значений переменных
# sed -i '/^export ALCHEMY_KEY=/d; /^export ALCHEMY_WS=/d; /^export TAIKO_KEY=/d' $HOME/.bash_profile
# Запрос и запись значения переменной ALCHEMY_KEY
if [ ! $ALCHEMY_KEY ]; then
    read -p "Введите ваш HTTP (ПРИМЕР: https://eth-sepolia.g.alchemy.com/v2/xZXxxxxxxxxxxc2q_bzxxxxxxxxxxWTN): " ALCHEMY_KEY
    echo 'Ваш ключ: ' $ALCHEMY_KEY
fi
sleep 1
# echo 'export ALCHEMY_KEY='$ALCHEMY_KEY >> $HOME/.bash_profile
# Запрос и запись значения переменной ALCHEMY_WS
if [ ! $ALCHEMY_WS ]; then
    read -p "Введите ваш WS (ПРИМЕР: wss://eth-sepolia.g.alchemy.com/v2/xZXxxxxxxxxxxc2q_bzxxxxxxxxxxWTN): " ALCHEMY_WS
    echo 'Ваш ключ: ' $ALCHEMY_WS
fi
sleep 1
# echo 'export ALCHEMY_WS='$ALCHEMY_WS >> $HOME/.bash_profile
# Запрос и запись значения переменной TAIKO_KEY
if [ ! $TAIKO_KEY ]; then
    read -p "Введите ваш приватный ключ от кошелька мм !ВАЖНО! без 0х!(ПРИМЕР: axxxcf5429bxxx9b66f9d973xxxxxxx151d93dff25550484c0efxxxxxadc): " TAIKO_KEY
    echo 'Ваш ключ: ' $TAIKO_KEY
fi
sleep 1
# echo 'export TAIKO_KEY='$TAIKO_KEY >> $HOME/.bash_profile
source $HOME/.profile
source $HOME/.bash_profile
echo "-----------------------------------------------------------------------------"
echo "Устанавливаем зависимости"
echo "-----------------------------------------------------------------------------"
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh) &>/dev/null
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh) &>/dev/null
echo "-----------------------------------------------------------------------------"
echo "Клонируем репрозиторий"
echo "-----------------------------------------------------------------------------"
git clone https://github.com/taikoxyz/simple-taiko-node.git
cd simple-taiko-node
cp .env.sample .env
echo "-----------------------------------------------------------------------------"
echo "Создаем env файл"
echo "-----------------------------------------------------------------------------"
sudo tee <<EOF >/dev/null $HOME/simple-taiko-node/.env
############################### DEFAULT #####################################
# Chain ID
CHAIN_ID=167005

# Exposed ports
PORT_L2_EXECTION_ENGINE_HTTP=8547
PORT_L2_EXECTION_ENGINE_WS=8548
PORT_L2_EXECTION_ENGINE_METRICS=6060
PORT_L2_EXECTION_ENGINE_P2P=30306
PORT_PROMETHEUS=9091
PORT_GRAFANA=9011

# Comma separated L2 execution engine bootnode URLs for P2P discovery bootstrap
BOOT_NODES=enode://77310934db4b38255ea172c9c770cdf69da2090a542d840569a863760ce415837a8fb310d52070a3ee9c4a665008c677cfc3b8c0850e8b40e2ab0b5006f31de4@43.153.67.131:30303,enode://5751376186499ec96d01554785183005a4fa5f1022d750c684d3925b03185a344ef42652430739fba998408bbdf13e3200a096b15196764aabd4bcaa4e941232@49.51.71.216:30303,enode://5ab86d28b1d3488163d6f401dd914f2d49f4f7cfd7fa48a12871ce2caea5c4693bf22366da4a7fc741704bf0e46e159bb3cb0fe0257453ff576ed91c409e050a@170.106.116.179:30303,enode://4efd43b7fef961cb3853dbafa89f07406ad59e3b4fb9e01bd2e191da0350af2c1714ce968249fc240036c6b4969282c7d28b90300ac687e5e034cad83110612c@35.192.136.10:30303,enode://519eb790453d85b570061b18b4f02d5c251e1af6e37f237e19d8827aabaa51ded0b3fc0272fbcdb7ebbb4f81216f2728210772d673d704d57773164dabc55fe6@34.136.126.66:30303,enode://8dbdd915aeced3b4bbd4c7f761b9bc9c5ee4aadf52a2bc00473b80a3ef5f5b01189bda589b9081f7ccde427296e5ce13c3a7079a797e151546882f6747ea2ca7@35.226.15.64:30303

# Taiko protocol contract addresses
TAIKO_L1_ADDRESS=0x6375394335f34848b850114b66A49D6F47f2cdA8
TAIKO_L2_ADDRESS=0x1000777700000000000000000000000000000001

# P2P
DISABLE_P2P_SYNC=false

############################### REQUIRED #####################################
# L1 Sepolia RPC endpoints (you will need an RPC provider such as Infura or Alchemy, or run a full Sepolia node yourself)
# If you are using a local Sepolia archive node, you can refer to it as "host.docker.internal" or use the local IP address
L1_ENDPOINT_HTTP=$ALCHEMY_KEY
L1_ENDPOINT_WS=$ALCHEMY_WS

############################### OPTIONAL #####################################
# If you want to be a prover who generates and submits zero knowledge proofs of proposed L2 blocks, you need to change
# `ENABLE_PROVER` to true and set `L1_PROVER_PRIVATE_KEY`.
ENABLE_PROVER=false
# How many provers you want to run concurrently, note that each prover will cost ~8 cores / ~16 GB memory.
ZKEVM_CHAIN_INSTANCES_NUM=1
# A L1 account (with balance) private key which will send the TaikoL1.proveBlock transactions.
# WARNING: only use a test account, pasting your private key in plain text here is not secure.
L1_PROVER_PRIVATE_KEY=$TAIKO_KEY

# If you want to be a proposer who proposes L2 execution engine's transactions in mempool to Taiko L1 protocol
# contract (be a "mining L2 node"), you need to change `ENABLE_PROPOSER` to true, then fill `L1_PROPOSER_PRIVATE_KEY`
# and `L2_SUGGESTED_FEE_RECIPIENT`
ENABLE_PROPOSER=false
# A L1 account (with balance) private key who will send TaikoL1.proposeBlock transactions
L1_PROPOSER_PRIVATE_KEY=
# A L2 account address who will be the tx fee beneficiary of the L2 blocks that you proposed
L2_SUGGESTED_FEE_RECIPIENT=
# Gas limit for proposeBlock transactions
PROPOSE_BLOCK_TX_GAS_LIMIT=800000

# Comma-delimited local tx pool addresses you want to prioritize, useful to set your proposer to only propose blocks with your prover's transactions
TXPOOL_LOCALS=

# Timeout when waiting for a propose or prove block transaction receipt to be seen, in seconds
WAIT_RECEIPT_TIMEOUT=360
EOF
echo "-----------------------------------------------------------------------------"
echo "Создаем env.l3 файл"
echo "-----------------------------------------------------------------------------"
sudo tee <<EOF >/dev/null $HOME/simple-taiko-node/.env.l3
############################### DEFAULT #####################################
# Chain ID
CHAIN_ID=167006

# Exposed ports
PORT_L3_EXECTION_ENGINE_HTTP=8549
PORT_L3_EXECTION_ENGINE_WS=8550
PORT_L3_EXECTION_ENGINE_METRICS=6061
PORT_L3_EXECTION_ENGINE_P2P=30307
PORT_PROMETHEUS=9092
PORT_GRAFANA=9002

# Comma separated L2 execution engine bootnode URLs for P2P discovery bootstrap
BOOT_NODES=enode://c7abe368a92fb398ec7008c137cff899896b12c579c57e4717fc9a3393d4fe76cead2b305c65817d35b116268e6796f22d1eb0ff38da263c081cd04d8a50e3dd@34.170.120.239:30303,enode://b35475fd231345ee37d22aa97c23acf4b712ee2c707525bfb087114b2a0a615051318136f301857ef6bfe61a3b6a94fee48dc66c1a7d2e2af765f8c25f1d5f5a@35.222.66.46:30303,enode://11a6183bb12a35ec66191832ff1d0b9f10d80cee68d8aa45cf271dfa872526fcd55c247806dbfab05ce5d50bf48c52ba3549d1d2a904e022aecad0e70e842121@34.71.74.144:30303,enode://6367d19c4608dc43531a3b30c85abf1997bf0ffc9b6c04f6bbd65206f8c325cc236ff224d0413fa402450674fc4fc96ef21bb7ded48c91579ecb68700e761a90@43.135.181.84:30303,enode://476400a939e2416d7e32d1aeb18f07a21ee5f89395775c5984effe30db8c7544e7e9cf2a5fe5d115ded278785cc5677860371e358fc165df90ee1f0038c4b1f9@43.153.21.92:30303,enode://a3f5f53c9665be5a97a64c99e0000612924f69670d70a46dbcc77b0407da435d8d7414a17c00d94d90ec3da46cc889d1dc6141f98faf61c8f0daa2fdac8286de@43.153.11.192:30303

# Taiko protocol contract addresses
TAIKO_L1_ADDRESS=0x4e7c942D51d977459108bA497FDc71ae0Fc54a00 # A TaikoL1 contract address on L2
PROVER_POOL_ADDRESS=0xC9580414A4372BDdBd8e19e01854DC0B2b1390Cf # A ProverPool contract address on L2
TAIKO_L2_ADDRESS=0x1000777700000000000000000000000000000001 # A TaikoL2 contract address on L3

# P2P
DISABLE_P2P_SYNC=false

############################### REQUIRED #####################################
# L2 RPC endpoints (you will need to run a fully synced L2 node to start a L3 node)
# If you are using a local Taiko L2 node, you can refer to it as "host.docker.internal" or use the local IP address
L2_ENDPOINT_HTTP=htttp://$(curl -s ifconfig.me):8547
L2_ENDPOINT_WS=ws://$(curl -s ifconfig.me):8548

############################### OPTIONAL #####################################
# If you want to be a prover who generates and submits zero knowledge proofs of proposed L3 blocks, you need to change
# `ENABLE_PROVER` to true and set `L2_PROVER_PRIVATE_KEY`.
ENABLE_PROVER=true
PROVE_UNASSIGNED_BLOCKS=true
# How many provers you want to run concurrently, note that each prover will cost ~16 cores / ~32 GB memory.
ZKEVM_CHAIN_INSTANCES_NUM=1
# A L2 account (with balance) private key which will send the TaikoL1.proveBlock transactions.
# WARNING: only use a test account, pasting your private key in plain text here is not secure.
L2_PROVER_PRIVATE_KEY=$TAIKO_KEY

# If you want to be a proposer who proposes L3 execution engine's transactions in mempool to Taiko L1 protocol (on L2)
# contract (be a "mining L3 node"), you need to change `ENABLE_PROPOSER` to true, then fill `L2_PROPOSER_PRIVATE_KEY`
# and `L3_SUGGESTED_FEE_RECIPIENT`
ENABLE_PROPOSER=false
# A L2 account (with balance) private key who will send TaikoL1.proposeBlock L2 transactions
L2_PROPOSER_PRIVATE_KEY=
# A L3 account address who will be the tx fee beneficiary of the L2 blocks that you proposed
L3_SUGGESTED_FEE_RECIPIENT=
# Gas limit for proposeBlock transactions
PROPOSE_BLOCK_TX_GAS_LIMIT=800000

# Comma-delimited local tx pool addresses you want to prioritize, useful to set your proposer to only propose blocks with your prover's transactions
TXPOOL_LOCALS=

# Timeout when waiting for a propose or prove block transaction receipt to be seen, in seconds
WAIT_RECEIPT_TIMEOUT=360
EOF
echo "-----------------------------------------------------------------------------"
echo "Запускаем ноду Taiko"
echo "-----------------------------------------------------------------------------"
source $HOME/simple-taiko-node/.env
source $HOME/simple-taiko-node/.env.l3
sleep 1
docker-compose -f $HOME/simple-taiko-node/docker-compose.yml --env-file .env up -d
docker compose -f $HOME/simple-taiko-node/docker-compose.l3.yml --env-file .env.l3 up -d
echo "-----------------------------------------------------------------------------"
echo "Нода обновлена и запущена"
echo "-----------------------------------------------------------------------------"
