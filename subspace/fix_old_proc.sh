#!/bin/bash

# Путь к файлу docker-compose.yml
FILE="$HOME/subspace_docker/docker-compose.yml"

# Проверяем, существует ли файл
if [ -f "$FILE" ]; then
    # Используем awk для обработки файла
    awk '/gemini-3g-2023-nov-07/ && !/-aarch64/ {print $0 "-aarch64"} !/gemini-3g-2023-nov-07/ || /-aarch64/ {print}' "$FILE" > temp.yml && mv temp.yml "$FILE"
    echo "Обновления были применены."
else
    echo "Файл $FILE не существует."
fi
