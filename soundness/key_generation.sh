#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

read -p "Сколько ключей нужно сгенерировать? " num_keys

if ! [[ "$num_keys" =~ ^[0-9]+$ ]]; then
    echo "Ошибка: Введите целое число!"
    exit 1
fi

output_file="keys.txt"
echo "Сохраняю ключи в файл: $output_file"
echo "===============================" > "$output_file"
echo "Сгенерированные ключи:" >> "$output_file"
echo "===============================" >> "$output_file"

for i in $(seq 1 $num_keys); do
    key_name="my-key-$i"
    echo "Генерирую ключ: $key_name"
    
    # Генерация ключа и сохранение в файл
    soundness-cli generate-key --name "$key_name" | tee -a "$output_file"
    
    echo "-------------------------------" >> "$output_file"
    sleep 1
done

echo "Все $num_keys ключей успешно созданы! Проверь файл $output_file"
