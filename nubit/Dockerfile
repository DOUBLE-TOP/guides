FROM ubuntu:22.04

# Add a non-root user
RUN groupadd -r nubit-user && useradd -r -g nubit-user nubit-user
USER root

# Install necessary dependencies
RUN apt-get update -y && \
    apt-get install -y curl tar

EXPOSE 26658
EXPOSE 2121

USER nubit-user
WORKDIR /home/nubit-user

RUN curl -sLO http://nubit.sh/nubit-bin/nubit-node-linux-x86_64.tar

RUN tar -xvf nubit-node-linux-x86_64.tar
RUN mv nubit-node-linux-x86_64 "/home/nubit-user/nubit-node"
RUN rm nubit-node-linux-x86_64.tar

WORKDIR /home/nubit-user/nubit-node

# Make start.sh executable and update it
RUN chmod +x start.sh
RUN sed -i -e '/\$BINARY \$NODE_TYPE start --metrics --metrics.tls=false --metrics.endpoint otel.nubit-alphatestnet-1.com:4318 --metrics.interval 3600s/{ N; s/\n/ / }' start.sh

# Specify the command to run when the container starts
CMD ["./start.sh"]
