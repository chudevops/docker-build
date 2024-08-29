#!/bin/sh

# 이미지 이름 및 태그
IMAGE_NAME="registry"
IMAGE_TAG="2"

# Docker 이미지를 pull
echo "Pulling Docker image ${IMAGE_NAME}:${IMAGE_TAG}..."
docker pull ${IMAGE_NAME}:${IMAGE_TAG}

echo "Docker image pulled successfully."
