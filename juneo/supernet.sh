#!/bin/bash 

. <(wget -qO- sh.doubletop.io) tools nodejs --force

cp $HOME/juneogo-binaries/plugins/srEr2XGGtowDVNQ6YgXcdUb16FGknssLTGUFYg7iMqESJ4h8e $HOME/.juneogo/plugins/srEr2XGGtowDVNQ6YgXcdUb16FGknssLTGUFYg7iMqESJ4h8e

chmod +x $HOME/.juneogo/plugins/srEr2XGGtowDVNQ6YgXcdUb16FGknssLTGUFYg7iMqESJ4h8e

git clone https://github.com/Juneo-io/juneojs-examples

cd $HOME/juneojs-examples

npm install

npx ts-node ./src/docs/crossJUNEtoJVM.ts

npx ts-node ./src/docs/crossJVMtoP.ts

supernet_id=$(npx ts-node ./src/supernet/createSupernet.ts | grep supernet | awk '{print $5}')

node_id=$(curl -s -X POST --data '{
    "jsonrpc":"2.0",
    "id"     :1,
    "method" :"info.getNodeID"
}' -H 'content-type:application/json' 127.0.0.1:9650/ext/info | jq -r .result.nodeID)

sed -i "s/const nodeId: string = 'NodeID-B2GHMQ8GF6FyrvmPUX6miaGeuVLH9UwHr'/const nodeId: string = '$node_id'/g" ./src/supernet/addSupernetValidator.ts
sed -i "s/const supernetId: string = 'ZxTjijy4iNthRzuFFzMH5RS2BgJemYxwgZbzqzEhZJWqSnwhP'/const supernetId: string = '$supernet_id'/g" ./src/supernet/addSupernetValidator.ts

sudo tee <<EOF >/dev/null $HOME/.juneogo/supernet_config.json
{
 "track-supernets":"$supernet_id"
}
EOF

sudo tee <<EOF >/dev/null /etc/systemd/system/juneo.service
[Unit]
Description=Juneo Node
After=network-online.target

[Service]
User=$USER
ExecStart=/usr/local/bin/juneogo --config-file="$HOME/.juneogo/supernet_config.json"
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl restart juneo
