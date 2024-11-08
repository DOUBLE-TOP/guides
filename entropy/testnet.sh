#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash &>/dev/null
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh | bash &>/dev/null

echo "-----------------------------------------------------------------------------"
echo "Testnet Entropy"
echo "-----------------------------------------------------------------------------"

if [ -z "$ENTROPY_MNEMONIC" ]; then
    echo "Введите сид фразу от кошелька, который будет использоваться для тестнета"
    read ENTROPY_MNEMONIC
fi

export ENTROPY_DEVNET='wss://testnet.entropy.xyz'
source $HOME/.profile

cargo install entropy-test-cli

echo "-----------------------------------------------------------------------------"
echo "1. Регистрируем аккаунт"
echo "-----------------------------------------------------------------------------"

entropy-test-cli register -m "$ENTROPY_MNEMONIC"

echo "-----------------------------------------------------------------------------"
echo "2. Вывод статуса"
echo "-----------------------------------------------------------------------------"

entropy-test-cli --chain-endpoint="$ENTROPY_DEVNET" status

echo "-----------------------------------------------------------------------------"
echo "3. Вывод статуса"
echo "-----------------------------------------------------------------------------"


echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"
