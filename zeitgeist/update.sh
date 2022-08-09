#!/bin/bash
sudo systemctl stop zeitgeist

rm -f $HOME/zeitgeist/target/release/zeitgeist

wget https://github.com/zeitgeistpm/zeitgeist/releases/download/v0.3.3/zeitgeist_parachain -O $HOME/zeitgeist/target/release/zeitgeist
# curl -o $HOME/battery-station-relay.json https://raw.githubusercontent.com/zeitgeistpm/polkadot/battery-station-relay/node/service/res/battery-station-relay.json
# curl -o $HOME/bs_parachain.json https://raw.githubusercontent.com/zeitgeistpm/zeitgeist/f43d0bb1a84cc157fc27b4388e0838db9020dd41/node/res/bs_parachain.json
chmod +x $HOME/zeitgeist/target/release/zeitgeist
# mkdir -p $HOME/.local/share/zeitgeist/chains/battery_station_mainnet/
if [ ! -e $HOME/zeitgeist_bk/secret_ed25519 ]; then
  mkdir -p $HOME/zeitgeist_bk/
  cp $HOME/.local/share/zeitgeist/rococo/chains/rococo_battery_station_relay_testnet/network/secret_ed25519 $HOME/zeitgeist_bk/
fi
if [ ! -e $HOME/zeitgeist_bk/battery_station_mainnet_secret_ed25519 ]; then
  cp $HOME/.local/share/zeitgeist/chains/battery_station_mainnet/network/secret_ed25519 $HOME/zeitgeist_bk/battery_station_mainnet_secret_ed25519
fi


# rm -rf $HOME/.local/share/zeitgeist/chains/zeitgeist/db
# rm -rf $HOME/.local/share/zeitgeist/chains/battery_station_mainnet/db
# rm -rf $HOME/.local/share/zeitgeist/rococo/chains/rococo_battery_station_relay_testnet/db

# sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
# Storage=persistent
# EOF
# sudo systemctl restart systemd-journald
#
# sudo tee <<EOF >/dev/null /etc/systemd/system/zeitgeist.service
# [Unit]
# Description=Zeitgeist Node
# After=network-online.target
# [Service]
# User=$USER
# Nice=0
# ExecStart=$HOME/zeitgeist/target/release/zeitgeist \
#     --bootnodes=/dns/bsr.zeitgeist.pm/tcp/30337/p2p/12D3KooWSBj4SXAz1ETTurW5PRAF1abyxXb9APAVs4vqBVr2NjRt \
#     --bootnodes=/dns/bsr.zeitgeist.pm/tcp/30337/ws/p2p/12D3KooWSBj4SXAz1ETTurW5PRAF1abyxXb9APAVs4vqBVr2NjRt \
#     --chain=$HOME/bs_parachain.json \
#     --name="$NODENAME | DOUBLETOP" \
#     --parachain-id=2050 \
#     --port=30333 \
#     --rpc-port=9933 \
#     --ws-port=9944 \
#     --rpc-external \
#     --ws-external \
#     --rpc-cors=all \
#     -- \
#     --bootnodes=/dns/bsr.zeitgeist.pm/tcp/30338/p2p/12D3KooWRuwKV1yt6fqPL6hsfPvJQ28pqmmTxNSDxEC4eLKagzjK \
#     --bootnodes=/dns/bsr.zeitgeist.pm/tcp/30338/ws/p2p/12D3KooWRuwKV1yt6fqPL6hsfPvJQ28pqmmTxNSDxEC4eLKagzjK \
#     --chain=$HOME/battery-station-relay.json \
#     --port=30334 \
#     --rpc-port=9934 \
#     --ws-port=9945
# Restart=always
# RestartSec=10
# LimitNOFILE=10000
# [Install]
# WantedBy=multi-user.target
# EOF
#
# sudo systemctl daemon-reload
# sudo systemctl enable zeitgeist
sudo systemctl restart zeitgeist
