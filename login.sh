#!/bin/bash

DOCKER_LOGIN=$(aws ecr get-login --no-include-email --region=ap-southeast-2)
sudo $DOCKER_LOGIN
