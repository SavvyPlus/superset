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

## Request SSL Certificate from AWS Certificate Manager

Using the AWS web console, go to Certificate Manager and request a certificate for `*.superset.savvybi.enterprises`

Use the DNS validation method.  When the certificate has been validated, copy the arn of the certificate to use in the nginx.yaml and superset.yaml deployment files

## Deploying Kubernetes Dashboard

From the top level of the git repository
1. `sudo docker run -it savvybi/superset-cluster-kops:0.1`
1. `kops export kubecfg --name=${NAME}`
1. From inside the superset-cluster-kops docker container, run the following to deploy the kubernetes dashboard:
`kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml`
1. `kops get secrets kube --type secret -oplaintext`
1. Copy the output from this and use it as the password for (username admin): https://api.superset.savvybi.enterprises/ui
1. `kops get secrets admin --type secret -oplaintext`
1. Copy the output from this and use it as the Token


## Deploying ExternalDNS for Kubernetes

From the top level of the git repository

`sudo docker run -v $(pwd)/k8s:/files -it savvybi/superset-cluster-kops:0.1`
1. `kops export kubecfg --name=${NAME}`

1. Edit the cluster config to add required iam policies: `kops edit cluster ${NAME}`
1. Copy the following yaml and add to the end of the cluster config in vi

```  
  additionalPolicies:
    node: |
      [
        {
          "Effect": "Allow",
          "Action": ["route53:ChangeResourceRecordSets"],
          "Resource": ["arn:aws:route53:::hostedzone/*"]
        },
        {
          "Effect": "Allow",
          "Action": ["route53:ListHostedZones","route53:ListResourceRecordSets"],
          "Resource": ["*"]
        }
      ]
```
1. Run `kops update cluster ${NAME} --yes`

1. Run `kops rolling-update cluster` to ensure that changes are applied

1. From inside the superset-cluster-kops docker container, run the following to deploy the superset application:
`kubectl create -f /files/external-dns.yaml`

1. From inside the superset-cluster-kops docker container, run the following to deploy a test nginx service:
`kubectl create -f /files/nginx.yaml`

1. Wait for 5-10 minutes and then check that ExternalDNS has correctly created a new DNS entry in Route53, by browsing: `http://nginx.superset.savvybi.enterprises`

## Deploying superset application

From the top level of the git repository

`sudo docker run -v $(pwd)/superset-app:/files -it savvybi/superset-cluster-kops:0.1`

1. `kops export kubecfg --name=${NAME}`
1. From inside the superset-cluster-kops docker container, run the following to deploy the superset application:
`kubectl create -f /files/superset.yaml`
1. From inside the superset-cluster-kops docker container, run the following to get the external facing url:
`kubectl describe service superset`
you should see something like:
`LoadBalancer Ingress:     a9c4e359f6d9711e8b31c068d3110b28-2094159502.ap-southeast-2.elb.amazonaws.com`
browsing to that location will give the superset login page
1. Wait for 10 minutes for ExternalDNS to generate a nice url and then browse to `http://superset-app.superset.savvybi.enterprises` - login with admin/pa55word

## SSL Certificate

From the top level of the git repository
`sudo docker run -v $(pwd)/superset-app:/files -it savvybi/superset-cluster-kops:0.1`

1. `aws acm request-certificate --domain-name superset.savvybi.enterprises --validation-method DNS --idempotency-token 91adc45q --subject-alternative-names *.superset.savvybi.enterprises`

1. Copy the returned arn eg: `arn:aws:acm:ap-southeast-2:547051082101:certificate/0a83ceab-4568-4bbb-a44c-605486e0018c`

1. For each of the pending validation records in the DomainValidationOptions:
`aws acm describe-certificate --certificate-arn arn:aws:acm:ap-southeast-2:547051082101:certificate/0a83ceab-4568-4bbb-a44c-605486e0018c --region ap-southeast-2 | jq .Certificate.DomainValidationOptions`

1. Go to https://ap-southeast-2.console.aws.amazon.com/acm/home?region=ap-southeast-2#/

## Deploying postgres
From the top level of the git repository
`sudo docker run -v $(pwd)/druid:/files -it savvybi/superset-cluster-kops:0.1`

1. From inside the superset-cluster-kops docker container, run the following
1. `kops export kubecfg --name=${NAME}`
1. `kubectl create -f /files/postgres/postgresql.yaml`

## Deploying zookeeper

If you have already created the k8s cluster, you will need to expand the cluster to at least 3 nodes.

From the top level of the git repository
`sudo docker run -v $(pwd)/druid:/files -it savvybi/superset-cluster-kops:0.1`

1. From inside the superset-cluster-kops docker container, run the following
1. `kops export kubecfg --name=${NAME}`
1. `kops edit ig nodes` and change to `maxSize: 3` and `minSize: 3`
1. Run the zookeeper deployment `kubectl apply -f /files/zookeeper.yaml`

## Configuring Helm
We use [helm](http://helm.sh) to allow us to find/install and update packages to the Kubernetes cluster.

Helm acts as a package manager similar to apt-get on ubuntu or yum on redhat/centos.

Helm has two components, a client and a server.  To install/initialise helm:
From the top level of the git repository

1. `sudo docker run -v $(pwd):/files -it savvybi/superset-cluster-kops:0.1`
1. `kops export kubecfg --name=${NAME}`
1. Make sure the cluster is up and running: `kops validate cluster`
1. Create a serviceaccount for Tiller: `kubectl create serviceaccount tiller --namespace kube-system`
1. Apply the correct RBAC profile: `kubectl apply -f /files/helm/rbac-config.yaml`
1. `kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller`
1. `kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'`
1. Init helm `helm init`
1. Install a chart from Helm: `helm install stable/postgresql`

More charts can be found: https://hub.kubeapps.com/

## Deploying druid from local charts
From the top level of the git repository
`sudo docker run -v $(pwd)/druid:/files -it savvybi/superset-cluster-kops:0.1`

1. From inside the superset-cluster-kops docker container, run the following
1. `kops export kubecfg --name=${NAME}`
1. Make sure the cluster is up and running: `kops validate cluster`
1. `helm install /files/helm/druid-charts/`


## Destroying the Superset cluster

If you need to completely delete the cluster:
From the top level of the git repository
`sudo docker run -v $(pwd)/superset-app:/files -it savvybi/superset-cluster-kops:0.1`

1. From inside the superset-cluster-kops docker container, run the following
1. `kops export kubecfg --name=${NAME}`
1. `kops delete cluster --name ${NAME} --yes`
