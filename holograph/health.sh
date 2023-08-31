#!/bin/bash

while true; do
    systemctl is-active --quiet holographd.service

    if [[ $? -ne 0 ]]; then
        echo "$(date) - Сервис holographd.service не работает. Попытка перезапуска..."
        systemctl restart holographd.service

        if [[ $? -eq 0 ]]; then
            echo "$(date) - Сервис успешно перезапущен!"
        else
            echo "$(date) - Произошла ошибка при попытке перезапустить сервис!"
        fi
    fi
    sleep 60m
done
