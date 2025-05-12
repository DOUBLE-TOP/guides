#!/bin/bash

echo "-----------------------------------------------------------------------------"
curl -s https://raw.githubusercontent.com/DOUBLE-TOP/tools/main/doubletop.sh | bash
echo "-----------------------------------------------------------------------------"


CONFIG_FILE="/opt/popcache/config.json"
GREEN='\033[0;32m'
NC='\033[0m' # No Color

service popcache stop
sudo apt install jq &>/dev/null


update_json_field() {
  local json_path=$1
  local field_name=$2
  local current_value=$(jq -r "$json_path" "$CONFIG_FILE")
  echo -en "Введите значение поля ${GREEN}${field_name}${NC} (сейчас: '${GREEN}${current_value}${NC}', Enter - оставить как есть): "
  read new_value
  if [ -n "$new_value" ]; then
    jq --arg value "$new_value" "$json_path = \$value" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
  else
    echo "Оставляем как есть значение поля  ${field_name}."
  fi
}


update_json_field '.identity_config.node_name' "node_name"
update_json_field '.identity_config.name' "name"
update_json_field '.identity_config.email' "email"
update_json_field '.identity_config.discord' "discord"


service popcache start
echo "Конфигурация успешно обновлена (в файле $CONFIG_FILE). Сервис перезапущен."
