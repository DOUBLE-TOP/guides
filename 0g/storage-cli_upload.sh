#!/bin/bash
echo "-----------------------------------------------------------------------------"
echo "Обновляем Go до v.1.22"
echo "-----------------------------------------------------------------------------"
bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/go.sh)

source $HOME/.profile

# Проверяем, существует ли директория 0g-storage-client и клонируем репозиторий, если она отсутствует
if [ ! -d "$HOME/0g-storage-client" ]; then
    git clone https://github.com/0glabs/0g-storage-client.git
fi

cd $HOME/0g-storage-client
go build
# Запрашиваем имя файла
read -p "Придумайте название файла (пример: random.txt): " filename

# Проверяем указано ли расширение
if [[ $filename != *.txt ]]; then
    filename="$filename.txt"
fi

# Создаем файл
TEST_FILE=$filename
./0g-storage-client gen --file $TEST_FILE
echo "-----------------------------------------------------------------------------"
echo "Файл $TEST_FILE успешно создан"
echo "-----------------------------------------------------------------------------"
# Присваиваем значения переменным
PRIVATE_KEY=$($HOME/go/bin/0gchaind keys unsafe-export-eth-key wallet2 --keyring-backend test)
BLOCKCHAIN_RPC_ENDPOINT=$(grep 'blockchain_rpc_endpoint =' $HOME/0g-storage-node/run/config.toml | cut -d '"' -f 2)
STORAGE_RPC_ENDPOINT=http://$(wget -qO- eth0.me):5678
CONTRACT=0xB7e39604f47c0e4a6Ad092a281c1A8429c2440d3

# Выводим параметры
echo -e "BLOCKCHAIN_RPC_ENDPOINT: $BLOCKCHAIN_RPC_ENDPOINT\nSTORAGE_RPC_ENDPOINT: $STORAGE_RPC_ENDPOINT\nPRIVATE_KEY: $PRIVATE_KEY\nCONTRACT: $CONTRACT"
echo "-------------------------------------------------------------------------------"

# Upload файл
while true; do
    ./0g-storage-client upload \
    --url $BLOCKCHAIN_RPC_ENDPOINT \
    --contract $CONTRACT \
    --key $PRIVATE_KEY \
    --node $STORAGE_RPC_ENDPOINT \
    --file $TEST_FILE \
    --gas-limit=700000

    if [ $? -eq 0 ]; then
        echo "---------------------------"
        echo "$TEST_FILE успешно загружен"
        echo "---------------------------"
        break
    else
        echo "----------------------------------------------------"
        echo "Ошибка при загрузке $TEST_FILE, повторяем попытку..."
        echo "----------------------------------------------------"
        sleep 5  # Ожидание перед повторной попыткой
    fi
done
