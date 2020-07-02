#!/bin/sh
DOMAIN=login.microsoftonline.com:443
PROXY_AUTH=root:root
PROXY_IP=10.233.96.129
PROXY_PORT=3128
SOCAT_PORT=443
REPO=magicalyak/socat
docker build --tag ${REPO} \
  --build-arg DOMAIN=${DOMAIN} \
  --build-arg PROXY_AUTH=${PROXY_AUTH} \
  --build-arg PROXY_IP=${PROXY_IP} \
  --build-arg PROXY_PORT=${PROXY_PORT} \
  --build-arg SOCAT_PORT=${SOCAT_PORT} .
docker push ${REPO}