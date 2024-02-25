#!/bin/bash

# Запрос пароля у пользователя
read -sp "Введите пароль для DUSK: " DUSK_PASS
echo # Новая строка после ввода пароля

# Создание каталога
mkdir -p $HOME/rusk
cd $HOME/rusk

# Создание start.sh
cat > start.sh <<'EOF'
#!/bin/bash

# Запись ключей восстановления в лог
/opt/dusk/bin/rusk recovery-keys >> /var/log/rusk_recovery.log

# Запись состояния восстановления в лог
/opt/dusk/bin/rusk recovery-state >> /var/log/rusk_recovery.log

# Проверка консенсусных ключей
/opt/dusk/bin/check_consensus_keys.sh

# Обнаружение IP-адресов и запись в конфиг
/opt/dusk/bin/detect_ips.sh > /opt/dusk/services/rusk.conf.default

# Запуск основного процесса
exec /opt/dusk/bin/rusk --config /opt/dusk/conf/rusk.toml --kadcast-bootstrap bootstrap1.testnet.dusk.network:9000 --kadcast-bootstrap bootstrap2.testnet.dusk.network:9000
EOF

# Создание Dockerfile
cat > Dockerfile <<EOF
FROM ubuntu:22.04

WORKDIR /opt/dusk

ENV RUST_BACKTRACE=full \\
    RUSK_PROFILE_PATH=/opt/dusk/rusk

# Установка необходимых пакетов и выполнение всех операций одним слоем
RUN apt update && apt install -y unzip curl jq net-tools logrotate dnsutils \\
    && mkdir -p /opt/dusk/bin \\
    && mkdir -p /opt/dusk/conf \\
    && mkdir -p /opt/dusk/rusk \\
    && mkdir -p /opt/dusk/services \\
    && mkdir -p /opt/dusk/installer \\
    && mkdir -p /root/.dusk/rusk-wallet \\
    && VERIFIER_KEYS_URL="https://nodes.dusk.network/keys" \\
    && LAST_STATE_URL="https://nodes.dusk.network/state/86920" \\
    && INSTALLER_URL="https://github.com/dusk-network/itn-installer/archive/refs/tags/v0.1.4.tar.gz" \\
    && WALLET_URL=$(curl -s "https://api.github.com/repos/dusk-network/wallet-cli/releases/latest" | jq -r  '.assets[].browser_download_url' | grep libssl3) \\
    && curl -so /opt/dusk/installer/installer.tar.gz -L "\$INSTALLER_URL" \\
    && tar xf /opt/dusk/installer/installer.tar.gz --strip-components=1 -C /opt/dusk/installer \\
    && mv /opt/dusk/installer/bin/* /opt/dusk/bin/ \\
    && mv /opt/dusk/installer/conf/* /opt/dusk/conf/ \\
    && mv /opt/dusk/installer/services/* /opt/dusk/services/ \\
    && chmod +x /opt/dusk/bin/* \\
    && ln -sf /opt/dusk/bin/rusk /usr/bin/rusk \\
    && curl -so /opt/dusk/installer/wallet.tar.gz -L "\$WALLET_URL" \\
    && mkdir -p /opt/dusk/installer/wallet \\
    && tar xf /opt/dusk/installer/wallet.tar.gz --strip-components 1 --directory /opt/dusk/installer/wallet \\
    && mv /opt/dusk/installer/wallet/rusk-wallet /opt/dusk/bin/ \\
    && chmod +x /opt/dusk/bin/rusk-wallet \\
    && ln -sf /opt/dusk/bin/rusk-wallet /usr/bin/rusk-wallet \\
    && mv /opt/dusk/conf/wallet.toml /root/.dusk/rusk-wallet/config.toml \\
    && curl -so /opt/dusk/installer/rusk-vd-keys.zip -L "\$VERIFIER_KEYS_URL" \\
    && unzip -o /opt/dusk/installer/rusk-vd-keys.zip -d /opt/dusk/rusk/ \\
    && curl -so /opt/dusk/installer/state.tar.gz -L "\$LAST_STATE_URL" \\
    && tar -xvf /opt/dusk/installer/state.tar.gz -C /opt/dusk/rusk/ \\
    && rm -rf /opt/dusk/installer

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
      - rusk-data:/opt/dusk
      - rusk-wallet:/root/.dusk
    ports:
      - "9900:9000"
      - "8980:8080"

volumes:
  rusk-data:
  rusk-wallet:
EOF

# Сборка контейнера
docker-compose build
docker-compose run dusk bash -c "echo \"DUSK_CONSENSUS_KEYS_PASS=\$DUSK_CONSENSUS_KEYS_PASS\" > /opt/dusk/services/dusk.conf"

# Выполнение команд в контейнере
docker-compose run dusk bash -c "rusk-wallet --password \$DUSK_CONSENSUS_KEYS_PASS create --seed-file /opt/dusk/seed.txt"
docker-compose run dusk bash -c "rusk-wallet --password \$DUSK_CONSENSUS_KEYS_PASS export -d /opt/dusk/conf -n consensus.keys"

# Запуск контейнера
docker-compose up -d

echo "Установка и запуск завершены."
