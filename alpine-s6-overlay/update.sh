#!/bin/sh
if [ -z "$1" ]
then 
  echo "No argument supplied, set registry to prireg:5000"
    REGISTRY="prireg:5000"
  else
    echo "Set registry to $1"
    REGISTRY=$1
fi

NAME=alpine-s6-overlay
TAG=3.12-2.0.0.1

docker build -t ${REGISTRY}/${NAME}:${TAG} -f Dockerfile.${TAG} . --network=host \
  && docker push ${REGISTRY}/${NAME}:${TAG}
