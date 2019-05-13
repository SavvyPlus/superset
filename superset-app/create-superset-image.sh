#!/bin/bash
LATEST_VERSION=$(sudo docker images --format "{{.Tag}}" solarbi/superset-app | sed 's/-dev$//')
echo $LATEST_VERSION
if [ -z "${LATEST_VERSION:+x}" ]; then
  echo "VERSION not set, using 1-dev";
  VERSION=1-dev
else
  VERSION=$((LATEST_VERSION+1))
  echo "VERSION set to '$VERSION'";
fi

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --output text --query 'Account')
echo "Using account: ${AWS_ACCOUNT_ID}"

DOCKER_LOGIN=$(aws ecr get-login --no-include-email --region=ap-southeast-2)
sudo $DOCKER_LOGIN

echo "Docker Build"
sudo docker build --build-arg VER=${VERSION} --rm . -t savvybi/superset-app:${VERSION} -t ${AWS_ACCOUNT_ID}.dkr.ecr.ap-southeast-2.amazonaws.com/savvybi/superset-app:${VERSION} -t ${AWS_ACCOUNT_ID}.dkr.ecr.ap-southeast-2.amazonaws.com/savvybi/superset-app:production

echo "Creating ECR repository: zawee/superset-app"
aws ecr create-repository --region=ap-southeast-2 --repository-name savvybi/superset-app ||:

echo "Pushing image to ECR"
sudo docker push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-southeast-2.amazonaws.com/savvybi/superset-app
