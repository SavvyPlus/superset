#!/bin/bash
LATEST_VERSION=$(docker images --format "{{.Tag}}" zawee/superset-app | sed 's/-dev$//')
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

DOCKER_LOGIN=$(aws ecr get-login --no-include-email --region=us-west-2)
$DOCKER_LOGIN

echo "Docker Build"
docker build --build-arg VER=${VERSION} --rm . -t zawee/superset-app:${VERSION} -t ${AWS_ACCOUNT_ID}.dkr.ecr.us-west-2.amazonaws.com/zawee/superset-app:${VERSION} -t ${AWS_ACCOUNT_ID}.dkr.ecr.us-west-2.amazonaws.com/zawee/superset-app:production

echo "Creating ECR repository: zawee/superset-app"
aws ecr create-repository --region=us-west-2 --repository-name zawee/superset-app ||:

echo "Pushing image to ECR"
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.us-west-2.amazonaws.com/zawee/superset-app
