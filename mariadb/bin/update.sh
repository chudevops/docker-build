#!/bin/sh

set -e

# 변수 설정
REGISTRY_URL="prireg:5000"
IMAGE_NAME=mariadb
IMAGE_TAG=10.3.23

# 레지스트리 주소가 제공되지 않으면 기본값 사용
if [ -z "$1" ]
then 
  echo "No registry URL provided, using default: ${DEFAULT_REGISTRY}"
    REGISTRY=${REGISTRY_URL}
  else
    echo "Using provided registry URL: $1"
    REGISTRY=$1
fi

# Docker 이미지 빌드
docker build -t ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} -f ../Dockerfile.${IMAGE_TAG} . --network=host

# 이미지를 빌드한 후 레지스트리에 푸시
docker push ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
