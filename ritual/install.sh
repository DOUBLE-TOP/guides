#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/docker.sh | bash &>/dev/null

echo "-----------------------------------------------------------------------------"
echo "Установка Foundry"
echo "-----------------------------------------------------------------------------"

# Create a new folder:
mkdir -p $HOME/foundry && cd foundry
curl -L https://foundry.paradigm.xyz | bash
source ~/.bashrc

# Run foundryup to ensure Foundry is fully installed:
foundryup

echo "-----------------------------------------------------------------------------"
echo "Установка Ritual Node"
echo "-----------------------------------------------------------------------------"

echo "Введите приватный ключ"
read private_key

echo "Введите Base RPC"
read base_rpc

# Clone locally
cd $HOME
git clone --recurse-submodules https://github.com/ritual-net/infernet-container-starter && cd infernet-container-starter

cp ./projects/hello-world/container/config.json deploy/config.json
docker compose -f deploy/docker-compose.yaml up -d

sed -i "s|\"rpc_url\":.*|\"rpc_url\": \"$base_rpc\",|" $HOME/infernet-container-starter/deploy/config.json
sed -i "s|\"registry_address\":.*|\"registry_address\": \"0x3B1554f346DFe5c482Bb4BA31b880c1C18412170\",|" $HOME/infernet-container-starter/deploy/config.json
sed -i "s|\"private_key\":.*|\"private_key\": \"$private_key\",|" $HOME/infernet-container-starter/deploy/config.json

sed -i "s|\"rpc_url\":.*|\"rpc_url\": \"$base_rpc\",|" $HOME/infernet-container-starter/projects/hello-world/container/config.json
sed -i "s|\"registry_address\":.*|\"registry_address\": \"0x3B1554f346DFe5c482Bb4BA31b880c1C18412170\",|" $HOME/infernet-container-starter/projects/hello-world/container/config.json
sed -i "s|\"private_key\":.*|\"private_key\": \"$private_key\",|" $HOME/infernet-container-starter/projects/hello-world/container/config.json

sed -i "s|address registry =.*|address registry = 0x3B1554f346DFe5c482Bb4BA31b880c1C18412170;|" $HOME/infernet-container-starter/projects/hello-world/contracts/script/Deploy.s.sol

sleep 30

docker restart deploy-fluentbit-1 infernet-anvil deploy-redis-1 infernet-node hello-world


nano ~/infernet-container-starter/deploy/config.json

<change your rpc url to alchemy>
ctrl x > y > enter

#임시파일(hello-world)을 위한 config파일 열기
nano ~/infernet-container-starter/projects/hello-world/container/config.json

<change your rpc url to alchemy>
ctrl x > y > enter

#Makefile 열어서 수정하기
nano ~/infernet-container-starter/projects/hello-world/contracts/Makefile

<change your rpc url to alchemy>
ctrl x > y > enter

#구성 초기화(한 줄씩 입력!!!!!!)
docker restart infernet-anvil
docker restart hello-world
docker restart infernet-node
docker restart deploy-fluentbit-1
docker restart deploy-redis-1 

#도커 구동 여부 확인
docker ps
<check if there’s 5 dockers running>

#파일 위치 이동
cd ~/infernet-container-starter

#make deploy 시작
project=hello-world make deploy-contracts

★copy your Deployed sayshello: 0x~~★

#CallContract 열어서 수정하기
nano ~/infernet-container-starter/projects/hello-world/contracts/script/CallContract.s.sol

<paste it to your saysgm = saysGm(0x~blahblah)>

#make call contract 시작
project=hello-world make call-contract