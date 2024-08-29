#!/bin/sh

REGISTRY_URL="prireg:5000"

if [ -z "$1" ]
then
  echo "No argument supplied, set registry to ${REGISTRY_URL}"
    REGISTRY=${REGISTRY_URL}
  else
    echo "Set registry to $1"
    REGISTRY=$1
fi

PULL_IMAGE=registry:2
IMAGE_NAME=registry
IMAGE_TAG=2

docker pull $PULL_IMAGE \
  && docker tag $PULL_IMAGE ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} \
  && docker rmi $PULL_IMAGE
