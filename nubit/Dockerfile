FROM ubuntu:22.04

ARG ARCH_STRING="linux-x86_64"
ARG MD5_NUBIT="650608532ccf622fb633acbd0a754686"
ARG MD5_NKEY="d474f576ad916a3700644c88c4bc4f6c"

USER root

RUN mkdir /home/nubit-user && mkdir /home/nubit-user/.nubit-light-nubit-alphatestnet-1
COPY .nubit-light-nubit-alphatestnet-1/ /home/nubit-user/.nubit-light-nubit-alphatestnet-1

# Add a non-root user
RUN groupadd -r nubit-user && \
    useradd -r -g nubit-user nubit-user && \
    mkdir -p /home/nubit-user && \
    chown -R nubit-user:nubit-user /home/nubit-user && \
    chmod -R 700 /home/nubit-user && \
    usermod -aG sudo nubit-user

# Install necessary dependencies
RUN apt-get update -y && \
    apt-get install -y curl tar wget

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
RUN wget https://nubit.sh/start.sh
RUN chmod +x start.sh

# Specify the command to run when the container starts
CMD ["./start.sh"]