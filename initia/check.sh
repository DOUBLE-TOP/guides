#!/bin/bash

sleep 60

# Время ожидания между измерениями (в секундах)
wait_time=60

# Запрос к внешнему API для получения последнего блока
external_block=$(curl -s -X GET "https://initia-testnet.api.kjnodes.com/cosmos/base/tendermint/v1beta1/blocks/latest" | jq -r '.block.header.height')

# Запрос к своей ноде для получения высоты последнего блока
local_block_start=$(curl -s -X GET "http://localhost:14657/abci_info" | jq -r '.result.response.last_block_height')

# Проверка, что оба значения были получены
if [[ -z "$external_block" || -z "$local_block_start" ]]; then
    echo "Не удалось получить значения блоков."
    exit 1
fi

# Ожидание
sleep $wait_time

# Запрос к своей ноде для получения высоты последнего блока после ожидания
local_block_end=$(curl -s -X GET "http://localhost:14657/abci_info" | jq -r '.result.response.last_block_height')

# Вычисление разницы блоков
blocks_to_catch_up=$((external_block - local_block_end))

# Проверка, что значение разницы блоков положительное
if [[ $blocks_to_catch_up -lt 0 ]]; then
    echo "Ваша нода опережает внешнюю ноду на $((-blocks_to_catch_up)) блоков."
    exit 0
fi

# Вычисление количества синхронизированных блоков за время ожидания
blocks_synced=$((local_block_end - local_block_start))

# Вычисление скорости синхронизации (блоки в секунду)
sync_speed=$(echo "scale=2; $blocks_synced / $wait_time" | bc)

# Вычисление времени до синхронизации в минутах
time_to_sync=$(echo "scale=2; ($blocks_to_catch_up / $sync_speed) / 60" | bc)

echo "Внешний блок: $external_block"
echo "Локальный блок (начало): $local_block_start"
echo "Локальный блок (конец): $local_block_end"
echo "Синхронизированные блоки за $wait_time секунд: $blocks_synced"
echo "Скорость синхронизации: $sync_speed блоков/сек"
echo "Осталось догнать: $blocks_to_catch_up блоков"
echo "Ожидаемое время синхронизации: $time_to_sync минут"
