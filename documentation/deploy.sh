#!/bin/bash

echo Pulling Docker image ...
docker pull docker.eidastest.se:5000/sigval-service:softhsm

echo Undeploying ...
docker rm svt-es-sigval --force

echo Re-deploying ...

docker run -d --name svt-es-sigval --restart=always \
  -p 9050:8080 -p 9059:8009 -p 9053:8443 -p 9058:8000 \
  -e "SPRING_CONFIG_ADDITIONAL_LOCATION=/opt/sigval/" \
  -e "TZ=Europe/Stockholm" \
  -v /etc/localtime:/etc/localtime:ro \
  -v /opt/docker/sigval-edusign-hsm:/opt/sigval \
  docker.eidastest.se:5000/sigval-service:softhsm

echo Proxy Service started...
