#!/bin/bash

sudo tee <<EOF >/dev/null $HOME/.shardeum/Dockerfile
FROM registry.gitlab.com/shardeum/server:latest                                                                                                                                         
                                                                                                                                                                                        
ARG RUNDASHBOARD=y
ENV RUNDASHBOARD=${RUNDASHBOARD}

RUN echo "deb http://ftp.de.debian.org/debian stable main" > /etc/apt/sources.list && \
    echo "deb-src http://ftp.de.debian.org/debian stable main" >> /etc/apt/sources.list && \
    apt-get update

RUN cd /tmp && apt download libcrypt1 && \
    dpkg-deb -x libcrypt1_1%3a4.4.33-2_amd64.deb  . && \
    cp -av lib/x86_64-linux-gnu/* /lib/x86_64-linux-gnu/ && \
    apt --fix-broken install -y

RUN apt-get install -y sudo
RUN apt-get install -y logrotate

# Create node user
RUN usermod -aG sudo node && \
 echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
 chown -R node /usr/local/bin /usr/local/lib /usr/local/include /usr/local/share
USER node

# Copy cli src files as regular user
WORKDIR /home/node/app
COPY --chown=node:node . .

# RUN ln -s /usr/src/app /home/node/app/validator

# Start entrypoint script as regular user
CMD ["./entrypoint.sh"]
EOF

docker-compose -f $HOME/.shardeum/docker-compose.yml up -d --build
