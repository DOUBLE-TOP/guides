#!/bin/bash

# Запрос пароля у пользователя
read -sp "Введите пароль для DUSK: " DUSK_PASS
echo

mkdir -p $HOME/rusk
cd $HOME/rusk

cat > start.sh <<EOF
#!/bin/bash

DIR="/opt/dusk"

if [ "\$(ls -A \$DIR)" ]; then
  echo "Cтартуем..."
else
  bash <(curl -s https://raw.githubusercontent.com/DOUBLE-TOP/guides/main/dusk/itn-installer.sh)
fi

# Запись ключей восстановления в лог
/opt/dusk/bin/rusk recovery-keys >> /var/log/rusk_recovery.log

# Запись состояния восстановления в лог
/opt/dusk/bin/rusk recovery-state >> /var/log/rusk_recovery.log

# Проверка консенсусных ключей
/opt/dusk/bin/check_consensus_keys.sh

# Обнаружение IP-адресов и запись в конфиг
/opt/dusk/bin/detect_ips.sh > /opt/dusk/services/rusk.conf.default

# Запуск основного процесса
exec /opt/dusk/bin/rusk --config /opt/dusk/conf/rusk.toml --kadcast-bootstrap bootstrap1.testnet.dusk.network:9000 --kadcast-bootstrap bootstrap2.testnet.dusk.network:9000 --http-listen-addr 0.0.0.0:8980 --kadcast-listen-address 0.0.0.0:9900
EOF


# Создание Dockerfile
cat > Dockerfile <<EOF
FROM ubuntu:22.04

WORKDIR /opt/dusk

ENV RUST_BACKTRACE=full \\
    RUSK_PROFILE_PATH=/opt/dusk/rusk

# Установка необходимых пакетов и выполнение всех операций одним слоем
RUN apt update && apt install -y unzip curl jq net-tools logrotate dnsutils

COPY start.sh /start.sh

RUN chmod +x /start.sh

CMD ["/start.sh"]
EOF

# Создание docker-compose.yml
cat > docker-compose.yml <<EOF
version: '3'
services:
  dusk:
    build:
      context: .
    environment:
      - DUSK_CONSENSUS_KEYS_PASS=$DUSK_PASS
    volumes:
      - ./dusk:/opt/dusk
      - ./.dusk:/root/.dusk
    ports:
      - "9900:9900"
      - "8980:8980"

EOF

# Сборка контейнера
docker-compose build
echo \"DUSK_CONSENSUS_KEYS_PASS=\$DUSK_CONSENSUS_KEYS_PASS\" > ./dusk/services/dusk.conf

# Выполнение команд в контейнере
docker-compose run dusk bash -c "/opt/dusk/bin/rusk-wallet --password \$DUSK_CONSENSUS_KEYS_PASS create --seed-file /opt/dusk/seed.txt"
docker-compose run dusk bash -c "/opt/dusk/bin/rusk-wallet --password \$DUSK_CONSENSUS_KEYS_PASS export -d /opt/dusk/conf -n consensus.keys"

# Запуск контейнера
docker-compose up -d

echo "Установка и запуск завершены."
