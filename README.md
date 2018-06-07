# Savvybi Superset

This project contains the infrastructure/code required to create a [kubernetes](https://kubernetes.io/)  cluster
and install [superset](https://superset.apache.org/)

## Creating the K8s cluster

Checkout the repo from github and:
1. `cd superset-cluster/k8s`
1. `./cluster.sh`
1. `sudo docker run -it savvybi/superset-cluster-kops:0.1`
1. From inside the superset-cluster-kops docker container, run the following to create the k8s spec
`kops create cluster --node-size=t2.large --zones=ap-southeast-2a,ap-southeast-2b --node-count=2 --name=${NAME}`
1. From inside the superset-cluster-kops docker container, run the following to use the spec to create the k8s cluster
`kops update cluster ${NAME} --yes`
