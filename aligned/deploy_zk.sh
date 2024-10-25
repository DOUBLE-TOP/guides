#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"
echo "Устанавливаем зависимости"
echo "-----------------------------------------------------------------------------"

curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/ufw.sh | bash
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/go.sh | bash
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/rust.sh | bash
source $HOME/.profile
source "$HOME/.cargo/env"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/foundry.sh | bash

echo "-----------------------------------------------------------------------------"
echo "Качаем проект и импортируем кошелек по приватному ключу"
echo "-----------------------------------------------------------------------------"

cd $HOME
git clone https://github.com/yetanotherco/aligned_layer.git && cd aligned_layer
cast wallet import --interactive wallet

echo "-----------------------------------------------------------------------------"
echo "Устанавливаем дополнительные зависимости и проходим квиз. Ответы(Nakamoto, Pacific, Green)."
echo "-----------------------------------------------------------------------------"

cd $HOME/aligned_layer/examples/zkquiz
make answer_quiz KEYSTORE_PATH=$HOME/.foundry/keystores/wallet

echo "-----------------------------------------------------------------------------"
echo "Удаляем все данные после деплоя"
echo "-----------------------------------------------------------------------------"

cd $HOME
rm -rf $HOME/aligned_layer
rm -rf $HOME/.foundry/keystores/wallet

echo "-----------------------------------------------------------------------------"
echo "Wish lifechange case with DOUBLETOP"
echo "-----------------------------------------------------------------------------"