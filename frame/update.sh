#!/bin/bash

cd $HOME/frame-validator
docker rm -f frame
docker pull public.ecr.aws/o8e2k8j7/nitro-node:frame
docker run -d --name frame --restart always -it --cpus="1.0" -v $(pwd)/node-data:/home/user/.frame -v $(pwd)/node-config/testnet.json:/home/user/testnet.json public.ecr.aws/o8e2k8j7/nitro-node:frame --conf.file testnet.json