#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

sudo systemctl stop dill

sed -i 's|ExecStart=.*|ExecStart='"$HOME"'/dill/dill-node --light --embedded-geth --datadir '"$HOME"'/dill/light_node/data/beacondata --genesis-state '"$HOME"'/dill/genesis.ssz --grpc-gateway-host 0.0.0.0 --initial-validators '"$HOME"'/dill/validators.json --block-batch-limit 128 --min-sync-peers 1 --minimum-peers-per-subnet 1 --andes --enable-debug-rpc-endpoints --suggested-fee-recipient 0x1a5E568E5b26A95526f469E8d9AC6d1C30432B33 --log-format json --verbosity info --log-file '"$HOME"'/dill/light_node/logs/dill.log --exec-http --exec-http.api eth,net,web3  --exec-syncmode full --exec-mine=false --accept-terms-of-use --embedded-validator --validator-datadir '"$HOME"'/dill/light_node/data/validatordata --wallet-password-file '"$HOME"'/dill/walletPw.txt --wallet-dir '"$HOME"'/dill/keystore --exec-port 30305 --exec-http.port 8945 --monitoring-port 8380|' /etc/systemd/system/dill.service

sudo systemctl daemon-reload
sudo systemctl start dill

echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"