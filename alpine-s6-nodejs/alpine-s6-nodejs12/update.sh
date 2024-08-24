#!/bin/sh

# 기본 레지스트리 URL 설정
DEFAULT_REGISTRY="prireg:5000"

# 레지스트리 URL 설정 (인자 제공 시 사용, 없을 경우 기본값 사용)
if [ -z "$1" ]
then 
  echo "No argument supplied, set registry to ${DEFAULT_REGISTRY}"
    REGISTRY=${DEFAULT_REGISTRY}
  else
    echo "Set registry to $1"
    REGISTRY=$1
fi

# 이미지 이름과 태그 설정
NAME=alpine-s6-node12
TAG=3.11-12.15.0

# 이미지 빌드 및 푸시
echo "Building and pushing Docker image ${REGISTRY}/${NAME}:${TAG}"
docker build -t ${REGISTRY}/${NAME}:${TAG} -f Dockerfile.${TAG} . \
  && docker push ${REGISTRY}/${NAME}:${TAG}

# 레지스트리 저장소와 태그 목록 조회
echo "Fetching registry repository information"
curl -s http://${REGISTRY}/v2/_catalog | jq .
curl -s http://${REGISTRY}/v2/${NAME}/tags/list | jq .
