#!/bin/bash

# Время ожидания между измерениями (в секундах)
wait_time=60
# Максимальное время ожидания логов (в секундах)
max_wait_time=600

# Функция для проверки логов на наличие растущих значений height
check_logs() {
    local last_height=0
    local elapsed_time=0

    while [[ $elapsed_time -lt $max_wait_time ]]; do
        # Чтение текущего высоты из логов
        current_height=$(journalctl -u 0g -n 100 --no-pager | grep 'height=' | tail -1 | sed -E 's/.*height=([0-9]+).*/\1/')
        
        # Проверка, если current_height это число и больше последнего высоты
        if [[ $current_height =~ ^[0-9]+$ ]] && [[ $current_height -gt $last_height ]]; then
            last_height=$current_height
            echo "Текущая высота в логах: $current_height"
            return 0
        fi

        echo "Ожидание запуска приложения... Текущая высота: $current_height"
        sleep 10
        elapsed_time=$((elapsed_time + 10))
    done

    echo "Нода не синхронизируется с сетью"
    exit 1
}

# Проверка логов перед началом синхронизации
check_logs

# Запрос к внешнему API для получения последнего блока
external_block=$(curl -s -X GET "0g-api.originstake.com/cosmos/base/tendermint/v1beta1/blocks/latest" | jq -r '.block.header.height')

# Запрос к своей ноде для получения высоты последнего блока
local_block_start=$(curl -s -X GET "http://localhost:12657/abci_info" | jq -r '.result.response.last_block_height')

# Проверка, что оба значения были получены
if [[ -z "$external_block" || -z "$local_block_start" ]]; then
    echo "Не удалось получить значения блоков."
    exit 1
fi

# Ожидание
sleep $wait_time

# Запрос к своей ноде для получения высоты последнего блока после ожидания
local_block_end=$(curl -s -X GET "http://localhost:12657/abci_info" | jq -r '.result.response.last_block_height')

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
