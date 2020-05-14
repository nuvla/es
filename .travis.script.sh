#!/bin/bash -xe

DOCKER_ORG="nuvla"
DOCKER_IMAGE="es"
DOCKER_TAG="7.7.0.0"

TAG=${DOCKER_ORG}/${DOCKER_IMAGE}:${DOCKER_TAG}

#
# generate image
#

docker build . --tag $TAG

#
# login to docker hub
#

unset HISTFILE
echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin

#
# push generated image
#

docker push $TAG
