# Savvybi Superset

This project contains the infrastructure/code required install [superset](https://superset.apache.org/). The installation is automatically done by [codepipeline](https://github.com/SavvyPlus/superset-CICD-cf). 

* Dockerfile is the file to build docker image
* superset-ss-dts.yaml is the file to deploy superset on eks
* buildspec.yml is the file used by codebuild
  