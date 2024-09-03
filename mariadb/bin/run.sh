#!/bin/sh

set -e

# 변수 설정
MARIADB_DATA_ROOT=/fsdata/mariadb
MARIADB_LOG_ROOT=/fslog/mariadb

MARIADB_CONTAINER_DATA_DIR=/mariadb
MARIADB_CONTAINER_LOG_DIR=/var/log/mariadb

MARIADB_ROOT_PASSWORD=mariadb
MARIADB_PORT=3306

REGISTRY_URL="prireg:5000"
IMAGE_NAME=mariadb
IMAGE_TAG=10.3.23
CONTAINER_NAME=mariadb
SERVICE_NAME=mariadb

# 기존 컨테이너가 실행 중인지 확인하고 중지 및 제거
if [ "$(docker ps -q -f name=${CONTAINER_NAME})" ]; then
    echo "Stopping and removing existing container '${CONTAINER_NAME}'."
    docker stop ${CONTAINER_NAME}
    docker rm ${CONTAINER_NAME}
fi

# Docker 컨테이너 실행
docker run -d \
      --name ${CONTAINER_NAME} \
      --label SERVICE_NAME=${SERVICE_NAME} \
      --network host \
      -e USRID=$(id -u) -e GRPID=$(id -g) \
      -e MARIADB_PORT=${MARIADB_PORT} \
      -e MARIADB_ROOT_PASSWORD=${MARIADB_ROOT_PASSWORD} \
      -v ${MARIADB_DATA_ROOT}:${MARIADB_CONTAINER_DATA_DIR} \
      -v ${MARIADB_LOG_ROOT}:${MARIADB_CONTAINER_LOG_DIR} \
      -v /etc/localtime:/etc/localtime:ro \
      -p ${MARIADB_PORT}:${MARIADB_PORT} \
      ${REGISTRY_URL}/${IMAGE_NAME}:${IMAGE_TAG}
