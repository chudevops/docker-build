#!/bin/sh

REGISTRY_URL="prireg:5000"
IMAGE_NAME=registry
IMAGE_TAG=2

docker run -d --restart always \
              --name prod-${IMAGE_NAME} \
              --user $(id -u):$(id -g) \
              -e REGISTRY_STORAGE_DELETE_ENABLED=true \
              -p 5000:5000 \
              -v /data/prod/registry:/var/lib/registry \
              -v /etc/localtime:/etc/localtime:ro \
              ${REGISTRY_URL}/${IMAGE_NAME}:${IMAGE_TAG}
