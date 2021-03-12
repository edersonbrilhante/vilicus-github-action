#!/bin/bash

# This script will run vilicus scan

set -e
set -u

function set_vars (){
  CMD='dockerize -wait http://vilicus:8080/healthz -wait-retry-interval 60s -timeout 2000s vilicus-client'
  TEMPLATE=/opt/vilicus/contrib/sarif.tpl
  CONFIG=/opt/vilicus/configs/conf.yaml
  OUTPUT=/artifacts/results.sarif
}

function push_image (){
  
  if [[ $IMAGE =~ "localhost:5000" ]]; then
    docker push $IMAGE
    IMAGE="${IMAGE/localhost:5000/localregistry.vilicus.svc:5000}" 
  fi
}

function download_docker_compose (){
  curl -o docker-compose.yml https://raw.githubusercontent.com/edersonbrilhante/vilicus/main/deployments/docker-compose.yml 
}

function run_docker_compose () {
  docker-compose up -d
}

function create_artifacts (){
  mkdir -p artifacts && chmod 777 artifacts
}

function run_scan (){
  docker run \
    -v ${PWD}/artifacts:/artifacts \
    --network container:vilicus \
    vilicus/vilicus:latest \
    sh -c "${CMD} -p ${CONFIG} -i ${IMAGE}  -t ${TEMPLATE} -o ${OUTPUT}"
}

set_vars
download_docker_compose
run_docker_compose
create_artifacts
push_image
run_scan