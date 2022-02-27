#!/usr/bin/env bash

# This script is only used to run the dockercontainer built by the makefile and mount the pwd
echo "[Script] Using docker: $(docker -v)"
export SOURCERER_CC_INPUT="/home/sourcerercc-user/data/$1"
export LINK_FROM="$(pwd)"
# may default to empty, will be ignored then
export PROJECTS_LIST="$1"
docker-compose build
# we do forced recreate so we ensure fresh containers
docker-compose up --force-recreate --abort-on-container-exit --exit-code-from alpine-sourcerercc