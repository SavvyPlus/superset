#!/bin/bash

DOCKER_LOGIN=$(aws ecr get-login --no-include-email --region=ap-southeast-2)
sudo $DOCKER_LOGIN

sudo docker build . -f base/Dockerfile -t druid-base:0.1 -t 547051082101.dkr.ecr.ap-southeast-2.amazonaws.com/savvybi/druid-base:0.1
sudo docker push 547051082101.dkr.ecr.ap-southeast-2.amazonaws.com/savvybi/druid-base:0.1

sudo docker build . -f broker/Dockerfile -t druid-broker:0.1 -t 547051082101.dkr.ecr.ap-southeast-2.amazonaws.com/savvybi/druid-broker:0.1
sudo docker push 547051082101.dkr.ecr.ap-southeast-2.amazonaws.com/savvybi/druid-broker:0.1

sudo docker build . -f coordinator/Dockerfile -t druid-coordinator:0.1 -t 547051082101.dkr.ecr.ap-southeast-2.amazonaws.com/savvybi/druid-coordinator:0.1
sudo docker push 547051082101.dkr.ecr.ap-southeast-2.amazonaws.com/savvybi/druid-coordinator:0.1

sudo docker build . -f historical/Dockerfile -t druid-historical:0.1 -t 547051082101.dkr.ecr.ap-southeast-2.amazonaws.com/savvybi/druid-historical:0.1
sudo docker push 547051082101.dkr.ecr.ap-southeast-2.amazonaws.com/savvybi/druid-historical:0.1

sudo docker build . -f middlemanager/Dockerfile -t druid-middlemanager:0.1 -t 547051082101.dkr.ecr.ap-southeast-2.amazonaws.com/savvybi/druid-middlemanager:0.1
sudo docker push 547051082101.dkr.ecr.ap-southeast-2.amazonaws.com/savvybi/druid-middlemanager:0.1

sudo docker build . -f overlord/Dockerfile -t druid-overlord:0.1 -t 547051082101.dkr.ecr.ap-southeast-2.amazonaws.com/savvybi/druid-overlord:0.1
sudo docker push 547051082101.dkr.ecr.ap-southeast-2.amazonaws.com/savvybi/druid-overlord:0.1
