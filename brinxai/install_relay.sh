#!/bin/bash
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"

echo "Устанавливаем софт (временной диапазон ожидания ~5-20 min.)"
echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/main.sh | bash &>/dev/null

echo "Удаляем BrixAI Relay докер контейнер если уже стоит."
docker rm -f brinxai_relay &>/dev/null
docker rm -f brinxai_relay_amd64 &>/dev/null
docker rm -f brinxai_relay_arm64 &>/dev/null

echo "Запускаем установщик BrixAI Relay"
ARCH=$(dpkg --print-architecture)

if [ "$ARCH" = "amd64" ]; then
    URL="https://raw.githubusercontent.com/admier1/BrinxAI-Relay-Nodes/refs/heads/main/install_brinxai_relay_amd64.sh"
    CONTAINER_NAME="brinxai_relay_amd64"
else
    URL="https://raw.githubusercontent.com/admier1/BrinxAI-Relay-Nodes/refs/heads/main/install_brinxai_relay_arm64.sh"
    CONTAINER_NAME="brinxai_relay_arm64"
fi

# Download script to temp file
tmpfile=$(mktemp)
curl -s "$URL" -o "$tmpfile"
bash -i "$tmpfile"
rm "$tmpfile"


echo "Фиксим видимость в кабинете"
VOLUME_PATH=$(docker inspect "$CONTAINER_NAME" --format '{{ range .Mounts }}{{ if eq .Destination "/etc/openvpn" }}{{ .Source }}{{ end }}{{ end }}')
if [ -z "$VOLUME_PATH" ]; then
  echo "Не удалось найти том /etc/openvpn в контейнере brinxai_relay_amd64"
  exit 1
fi
TA_KEY_PATH=$(find "$VOLUME_PATH" -type f -name "ta.key" | head -n 1)
if [ -z "$TA_KEY_PATH" ]; then
  echo "Файл ta.key не найден в $VOLUME_PATH"
  exit 1
fi
DEST_PATH="/var/lib/docker/volumes/openvpn_data/_data/"
cp "$TA_KEY_PATH" "$VOLUME_PATH"
#cp "$TA_KEY_PATH" "$DEST_PATH"
if [ $? -eq 0 ]; then
  echo "Файл ta.key успешно скопирован в $VOLUME_PATH"
else
  echo "Ошибка копирования файла"
fi
#CONF_FILE="/var/lib/docker/volumes/openvpn_data/_data/openvpn.conf"
CONF_FILE="${VOLUME_PATH}/openvpn.conf"
sed -i 's/^push "push "redirect-gateway def1 bypass-dhcp""/push "redirect-gateway def1 bypass-dhcp"/' "$CONF_FILE"

echo "Перезапускаем контейнер"
docker restart "$CONTAINER_NAME"
