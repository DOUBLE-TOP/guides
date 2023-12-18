#!/bin/bash

docker rm -f frame
docker pull public.ecr.aws/o8e2k8j7/nitro-node:frame
docker run -d --name frame --restart always -it --cpus="1.0" --memory="4g" -v $(pwd)/node-data:/home/user/.frame -v $(pwd)/node-config/testnet.json:/home/user/testnet.json public.ecr.aws/o8e2k8j7/nitro-node:frame --conf.file testnet.json