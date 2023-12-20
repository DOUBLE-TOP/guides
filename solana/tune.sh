#!/bin/bash

# Функция для установки параметра
set_param() {
    local param=$1
    local value=$2
    local file="/etc/sysctl.conf"

    # Проверяем, есть ли уже параметр в файле
    if grep -q "^${param}=" "$file"; then
        # Параметр найден, обновляем его значение
        sudo sed -i "s/^${param}=.*/${param}=${value}/" "$file"
    else
        # Параметра нет, добавляем его в конец файла
        echo "${param}=${value}" | sudo tee -a "$file" > /dev/null
    fi
}

# Устанавливаем параметры
set_param "vm.max_map_count" "1000000"
set_param "net.core.optmem_max" "0"
set_param "net.core.netdev_max_backlog" "0"
set_param "net.core.wmem_default" "134217728"
set_param "net.core.rmem_default" "134217728"
set_param "net.core.wmem_max" "134217728"
set_param "net.core.rmem_max" "134217728"

# Применяем изменения
sudo sysctl -p
