#!/bin/bash
VERSION=$1
if [ -z "${VERSION:+x}" ]; then
  echo "VERSION not set, using 0.1-dev";
  VERSION=0.1-dev
else
  echo "VERSION set to '$VERSION'";
fi

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --output text --query 'Account')
echo "Using account: ${AWS_ACCOUNT_ID}"

DOCKER_LOGIN=$(aws ecr get-login --no-include-email --region=ap-southeast-2)
sudo $DOCKER_LOGIN

sudo docker build --build-arg VER=${VERSION} --rm . -t savvybi/superset-app:${VERSION} -t ${AWS_ACCOUNT_ID}.dkr.ecr.ap-southeast-2.amazonaws.com/savvybi/superset-app:${VERSION}

echo "Creating ECR repository: savvybi/superset-app"
aws ecr create-repository --region=ap-southeast-2 --repository-name savvybi/superset-app ||:

echo "Pushing image to ECR"
sudo docker push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-southeast-2.amazonaws.com/savvybi/superset-app
