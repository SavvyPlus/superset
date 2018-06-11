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
1. From inside the superset-cluster-kops docker container, run the following to generate the kubectl config:
`kops export kubecfg --name=${NAME}`
1. From inside the superset-cluster-kops docker container, run the following to validate that the cluster is ready:
`kops validate cluster`

## Deploying superset application

From the top level of the git repository

`sudo docker run -v $(pwd)/superset-app:/files -it savvybi/superset-cluster-kops:0.1`

1. From inside the superset-cluster-kops docker container, run the following to deploy the superset application:
`kubectl create -f /files/superset.yaml`
1. From inside the superset-cluster-kops docker container, run the following to get the external facing url:
`kubectl describe service superset`
you should see something like:
`LoadBalancer Ingress:     a9c4e359f6d9711e8b31c068d3110b28-2094159502.ap-southeast-2.elb.amazonaws.com`
browsing to that location will give the superset login page
