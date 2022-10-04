#!/bin/bash

cd $HOME
sudo apt-get update
sudo apt-get install libsnappy-dev libc6-dev libc6 unzip -y

wget https://github.com/NethermindEth/nethermind/releases/download/1.14.2/nethermind-linux-amd64-1.14.2-08354f9-20220915.zip
unzip nethermind-linux-amd64-1.14.2-08354f9-20220915.zip -d nethermind
rm -f nethermind-linux-amd64-1.14.2-08354f9-20220915.zip

sudo bash -c 'echo "nethermind hard nofile 1000000" >> /etc/security/limits.d/nethermind.conf'
sudo bash -c 'echo "nethermind hard nofile 1000000" >> /etc/security/limits.d/nethermind.conf'

sudo tee <<EOF >/dev/null $HOME/nethermind/configs/xdai_archive.cfg
{
  "Init": {
    "ChainSpecPath": "chainspec/xdai.json",
    "GenesisHash": "0x4f1dd23188aab3a76b463e4af801b52b1248ef073c648cbdc4c9333d3da79756",
    "BaseDbPath": "nethermind_db/xdai_archive",
    "LogFileName": "xdai_archive.logs.txt",
    "MemoryHint": 1024000000
  },
  "Mining": {
    "MinGasPrice": "1000000000"
  },
  "EthStats": {
    "Name": "Nethermind xDai"
  },
  "Metrics": {
    "NodeName": "xDai Archive"
  },
  "Bloom":
  {
    "IndexLevelBucketSizes" : [16, 16, 16]
  },
  "Pruning": {
    "Mode": "None"
  },
  "JsonRpc": {
    "Enabled": true,
    "Timeout": 20000,
    "Host": "127.0.0.1",
    "Port": 8545,
    "EnabledModules": [
      "Eth",
      "AccountAbstraction",
      "Subscribe",
      "TxPool",
      "Web3",
      "Personal",
      "Proof",
      "Net",
      "Parity",
      "Health",
      "Trace"
    ]
  }
}
EOF

sudo tee <<EOF >/dev/null /etc/systemd/system/nethermind.service
[Unit]
Description=Nethermind Node
Documentation=https://docs.nethermind.io
After=network.target

[Service]
User=$USER
WorkingDirectory=$HOME
ExecStart=$HOME/nethermind/Nethermind.Runner --config xdai_archive --datadir $HOME/xdai_archive --JsonRpc.Enabled true --JsonRpc.Host 0.0.0.0
Restart=on-failure
LimitNOFILE=1000000

[Install]
WantedBy=default.target
EOF


sudo systemctl daemon-reload
sudo systemctl enable nethermind
sudo systemctl start nethermind.service
