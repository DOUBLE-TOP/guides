#!/bin/bash

# Останавливаем сервис subspace
sudo systemctl stop subspace

# Определение уровня поддержки процессора
LEVEL=$(awk '
BEGIN {
    while (!/flags/) if (getline < "/proc/cpuinfo" != 1) exit 1
    if (/lm/&&/cmov/&&/cx8/&&/fpu/&&/fxsr/&&/mmx/&&/syscall/&&/sse2/) level = 1
    if (level == 1 && /cx16/&&/lahf/&&/popcnt/&&/sse4_1/&&/sse4_2/&&/ssse3/) level = 2
    if (level == 2 && /avx/&&/avx2/&&/bmi1/&&/bmi2/&&/f16c/&&/fma/&&/abm/&&/movbe/&&/xsave/) level = 3
    if (level == 3 && /avx512f/&&/avx512bw/&&/avx512cd/&&/avx512dq/&&/avx512vl/) level = 4
    print level; 
}')

# Выбор URL для скачивания на основе уровня
if (( LEVEL >= 4 )); then
    URL="https://github.com/subspace/pulsar/releases/download/v0.6.5-alpha/pulsar-ubuntu-x86_64-skylake-v0.6.5-alpha"
else
    URL="https://github.com/subspace/pulsar/releases/download/v0.6.5-alpha/pulsar-ubuntu-x86_64-v2-v0.6.5-alpha"
fi

# Удаляем старую версию, скачиваем новую и устанавливаем
rm -f /usr/local/bin/pulsar
wget -O pulsar $URL
sudo chmod +x pulsar
sudo mv pulsar /usr/local/bin/

# Перезапуск сервиса subspace
sudo systemctl restart subspace
