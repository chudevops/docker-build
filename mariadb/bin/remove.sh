#!/bin/sh

set -e

# 변수 설정
MARIADB_DATA_ROOT=/fsdata/mariadb
MARIADB_LOG_ROOT=/fslog/mariadb

REGISTRY_URL="prireg:5000"
IMAGE_NAME=mariadb
IMAGE_TAG=10.3.23
CONTAINER_NAME=mariadb

# 컨테이너 중지 및 삭제
docker stop ${CONTAINER_NAME} || echo "The container is already stopped."
docker rm ${CONTAINER_NAME} || echo "The container is already removed."

# 이미지 삭제
docker rmi ${REGISTRY_URL}/${IMAGE_NAME}:${IMAGE_TAG} || echo "The image is already removed."

# 로그 및 데이터 디렉터리 내용 삭제
if [ -d "${MARIADB_LOG_ROOT}" ]; then
    rm -rf ${MARIADB_LOG_ROOT}/*
else
    echo "Log directory does not exist: ${MARIADB_LOG_ROOT}"
fi

if [ -d "${MARIADB_DATA_ROOT}" ]; then
    rm -rf ${MARIADB_DATA_ROOT}/*
else
    echo "Data directory does not exist: ${MARIADB_DATA_ROOT}"
fi

echo "All MariaDB-related resources have been deleted."
