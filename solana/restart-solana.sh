#!/bin/bash

#####    CONFIG    ##################################################################################################
solana_bin="$HOME/.local/share/solana/install/active_release/bin/solana"
solana_dir="$HOME"
ledger_dir="$HOME/ledger"
slot_time=0.4  # Среднее время генерации одного слота в секундах
snapshot_interval=25000
incremental_snapshot_interval=2500
#####  THRESHOLD  ###################################################################################################
slot_threshold=10
snapshot_threshold=18000 # 2 часа [15000 = 1.4 часа]
incremental_snapshot_threshold=300 # 2 минуты
#####  END CONFIG  ##################################################################################################

check_config () {
    rm -rf $HOME/monitor
    timeout 2s solana-validator --ledger /root/ledger monitor > $HOME/monitor
    if [ -z $HOME/monitor ]; then echo "Файл monitor не найден"; exit 1; fi
    if [ -z $solana_bin ]; then echo "Проверьте путь к бинарнику Solana"; exit 1; fi
    if [ -z $solana_addr ]; then echo "Не удалось получить адрес Solana"; exit 1; fi
}

check_vars () {
    solana_addr=$($solana_bin address)
        if [ -z $solana_addr ]; then echo "Проверьте путь к бинарнику Solana"; exit 1; fi
    cli=$($solana_bin --version | grep client: | sed 's/.*client://; s/)//')
        if [ -z $cli ]; then echo "Проверьте путь к бинарнику Solana"; exit 1; fi
    cli_version=$($solana_bin --version | awk '{ print $2 }')
        if [ -z $cli_version ]; then echo "Проверьте путь к бинарнику Solana"; exit 1; fi
    slot_now=$(grep "Finalized Slot" monitor | awk -F 'Finalized Slot: ' '{print $2}' | awk '{print $1}')
        if [ -z $slot_now ]; then echo "Ошибка получения значения текущего слота"; exit 1; fi
    slot_next=$(tail -f $solana_dir/solana.log | awk -v addr="$solana_addr" '/'"$solana_addr"'.+within slot/ {print ($18-$12)*0.459/60; exit}')
        if [ -z $slot_next ]; then echo "Ошибка получения значения времени следующего назначенного слота"; exit 1; fi
    snapshot_slot=$(grep "Full Snapshot Slot" monitor | awk -F 'Full Snapshot Slot: ' '{print $2}' | awk '{print $1}')
        if [ -z $snapshot_slot ]; then echo "Ошибка получения значения слота на котором был сделал фулл снепшот"; exit 1; fi
    incremental_snapshot_slot=$(grep "Incremental Snapshot Slot" monitor | awk -F 'Incremental Snapshot Slot: ' '{print $2}' | awk '{print $1}')
        if [ -z $incremental_snapshot_slot ]; then echo "Ошибка получения значения слота на котором был сделал инкрементальный снепшот"; exit 1; fi
    latest_snapshot=$(ls -t $ledger_dir/snapshot-* | head -n 1)
    snapshot_time=$(stat -c %Y "$latest_snapshot")
    snapshot_date=$(date -d @$snapshot_time +'%H:%M')
        if [ -z $snapshot_date ]; then echo "Ошибка получения значения времени на котором был сделал фулл снепшот"; exit 1; fi
    latest_incremental_snapshot=$(ls -t $ledger_dir/incremental-snapshot-* | head -n 1)
    incremental_snapshot_time=$(stat -c %Y "$latest_incremental_snapshot")
    incremental_snapshot_date=$(date -d @$incremental_snapshot_time +'%H:%M')
        if [ -z $incremental_snapshot_date ]; then echo "Ошибка получения значения времени на котором был сделал инкрементальный снепшот"; exit 1; fi
}

show_now () {
    echo -e "\033[1;97m-----------------------------------------------------------------------------"
    echo -e "New CLI Version - $cli_version "
    echo -e "CLI client - $cli "
    echo -e "Validator Address - $solana_addr\033[0m"
    echo -e "\033[1;95m-----------------------------------------------------------------------------"
    date
    echo -e "Текущий блок \\ $slot_now \\"
    echo -e "Новый слот через - $slot_next минут"
    echo -e "Фулл снепшот создан - в $snapshot_date UTC на блоке $snapshot_slot"
    echo -e "Инкрементальный снепшот создан - в $incremental_snapshot_date UTC на блоке $incremental_snapshot_slot"
    echo -e "-----------------------------------------------------------------------------\033[0m"
}

show_progress() {
    local duration=$1
    local message=$2
    local elapsed=0
    local total_seconds=$(echo "$duration * 60" | bc)
    while (( $(echo "$elapsed < $total_seconds" | bc -l) )); do
        local progress=$(echo "$elapsed / $total_seconds * 100" | bc -l | awk '{printf "%.0f", $1}')
        local eta=$(echo "($total_seconds - $elapsed) / 60" | bc -l | awk '{printf "%.1f", $1}')
        echo -ne "$message: ["
        for (( i = 0; i < 50; i++ )); do
            if (( i < progress / 2 )); then
                echo -n "="
            else
                echo -n " "
            fi
        done
        echo -ne "] $progress%  ETA ${eta} min \r"
        sleep 1
        elapsed=$(echo "$elapsed + 1" | bc)
    done
    echo
}

restart_script() {
  echo -e "\033[0;31mПерезапуск скрипта...\033[0m"
  exec bash "$0" "$@"
}

check_slot_next() {
    if (( $(echo "$slot_next > $slot_threshold" | bc ) )); then 
        check_snapshot
    else
        wait_for_new_slot
    fi
}

check_snapshot() {
    snapshot_diff=$(($slot_now - $snapshot_slot))
    if (( $(echo "$snapshot_diff < $snapshot_threshold" | bc ) )); then 
        check_incremental_snapshot
    else
        wait_for_new_snapshot
    fi
}

check_incremental_snapshot() {
    incremental_snapshot_diff=$(($slot_now - $incremental_snapshot_slot))
    if (( $(echo "$incremental_snapshot_diff < $incremental_snapshot_threshold" | bc ) )); then
        solana_restart
    else
        wait_for_new_incremental_snapshot
    fi
}

wait_for_new_slot() {
    show_progress "$slot_next" "Ожидаем новый слот"
    restart_script
}

wait_for_new_snapshot() {
    next_snapshot_slot=$((snapshot_slot + snapshot_interval))
    slots_until_next_snapshot=$((next_snapshot_slot - slot_now))
    time_until_next_snapshot=$(echo "$slots_until_next_snapshot * $slot_time" | bc)
    time_until_next_snapshot_in_minutes=$(echo "$time_until_next_snapshot / 60" | bc)
    show_progress "15" "Ожидаем новый снепшот"
    restart_script
}

wait_for_new_incremental_snapshot() {
    next_incremental_snapshot_slot=$((incremental_snapshot_slot + incremental_snapshot_interval))
    slots_until_next_incremental_snapshot=$((next_incremental_snapshot_slot - slot_now))
    time_until_next_incremental_snapshot=$(echo "$slots_until_next_incremental_snapshot * $slot_time" | bc)
    time_until_next_incremental_snapshot_in_minutes=$(echo "$time_until_next_incremental_snapshot / 60" | bc)
    show_progress "0.5" "Ожидаем новый инкрементальный снепшот"
    restart_script
}

solana_restart() {
    echo -e "Выполняем sudo systemctl restart solana"
    sudo systemctl restart solana
}

check_vars
check_config
show_now
check_slot_next
