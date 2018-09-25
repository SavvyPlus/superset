# Savvybi Superset

This project contains the infrastructure/code required to create a [kubernetes](https://kubernetes.io/)  cluster
and install [superset](https://superset.apache.org/)

## Creating the K8s cluster
Inside the AWS console, create the VPC with the correct name.
Inside the AWS console, create an internet gateway with the correct name and associate this IGW with the VPC just created.

Checkout the repo from github and set these variables:
1. `cd superset-cluster/k8s`
1. `./cluster.sh`
1. `sudo docker run -v $(pwd)/k8s:/files -it savvybi/superset-cluster-kops:0.1`
1. From inside the container export these env vars
1. `export KOPS_STATE_STORE=s3://savvybi-superset-dts-state-store`
1. `export NAME=aws2-vpc-ss-dts.savvybi.enterprises`
1. `kops create -f /files/aws2-vpc-ss-dts.savvybi.enterprises.yaml`
1. `kops create secret --name aws2-vpc-ss-dts.savvybi.enterprises sshpublickey admin -i ~/.ssh/id_rsa.pub`
1. `kops update cluster aws2-vpc-ss-dts.savvybi.enterprises --yes`

## Configuring environment in container
After launching the `superset-cluster-kops` container, but before running the commands in the superset-cluster-kops container, run the following to configure the correct environment variables etc.

`/files/env-dts.sh`

### LEGACY - do not use now
1. From inside the superset-cluster-kops docker container, run the following to create the k8s spec
`kops create cluster --node-size=t2.large --zones=ap-southeast-2b --node-count=6 --name=${NAME} --vpc=${VPC} --subnets=${SUBNET_IDS}`
1. `kops edit cluster ${NAME}`
1. Check that the networkCIDR and networkID values match the env vars exported
1. From inside the superset-cluster-kops docker container, run the following to use the spec to create the k8s cluster
`kops update cluster ${NAME} --yes`
1. From inside the superset-cluster-kops docker container, run the following to generate the kubectl config:
`kops export kubecfg --name=${NAME}`
1. From inside the superset-cluster-kops docker container, run the following to validate that the cluster is ready:
`kops validate cluster`

## Configure correct DNS
`ID=$(uuidgen) && aws route53 create-hosted-zone --name <superset subdomain>.savvybi.enterprises --caller-reference $ID | jq .DelegationSet.NameServers`

Copy the list of NameServers

`aws route53 list-hosted-zones | jq '.HostedZones[] | select(.Name=="savvybi.enterprises.") | .Id'`

Copy the parent hostedzone id

Edit `k8s/subdomain.json` to add the name servers listed earlier

`aws route53 change-resource-record-sets --hosted-zone-id <parent-zone-id> --change-batch file://subdomain.json`

## Request SSL Certificate from AWS Certificate Manager

Using the AWS web console, go to Certificate Manager and request a certificate for `*.aws2-vpc-ss-dts.savvybi.enterprises`

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
`kubectl create -f /files/nginx-ss-dts.yaml`

1. Wait for 5-10 minutes and then check that ExternalDNS has correctly created a new DNS entry in Route53, by browsing: `http://nginx.aws2-vpc-ss-dts.savvybi.enterprises`

## Deploying superset application

From the top level of the git repository

`sudo docker run -v $(pwd):/files -it savvybi/superset-cluster-kops:0.1`

1. `/files/k8s/env-dts.sh`
1. From inside the superset-cluster-kops docker container, run the following to deploy the superset application:
`kubectl create -f /files/superset-app/superset-ss-dts.yaml`
1. From inside the superset-cluster-kops docker container, run the following to get the external facing url:
`kubectl describe service superset`
you should see something like:
`LoadBalancer Ingress:     a9c4e359f6d9711e8b31c068d3110b28-2094159502.ap-southeast-2.elb.amazonaws.com`
browsing to that location will give the superset login page
1. Wait for 10 minutes for ExternalDNS to generate a nice url and then browse to `http://demo-app.aws2-vpc-ss-dts.savvybi.enterprises` - login with admin/pa55word

## SSL Certificate

From the top level of the git repository
`sudo docker run -v $(pwd)/superset-app:/files -it savvybi/superset-cluster-kops:0.1`

1. `aws acm request-certificate --domain-name aws2-vpc-ss-dts.savvybi.enterprises --validation-method DNS --idempotency-token 91adc45q --subject-alternative-names *.aws2-vpc-ss-dts.savvybi.enterprises`

1. Copy the returned arn eg: `arn:aws:acm:ap-southeast-2:547051082101:certificate/0a83ceab-4568-4bbb-a44c-605486e0018c`

1. For each of the pending validation records in the DomainValidationOptions:
`aws acm describe-certificate --certificate-arn arn:aws:acm:ap-southeast-2:547051082101:certificate/0a83ceab-4568-4bbb-a44c-605486e0018c --region ap-southeast-2 | jq .Certificate.DomainValidationOptions`

1. Go to https://ap-southeast-2.console.aws.amazon.com/acm/home?region=ap-southeast-2#/

## Deploying postgres
From the top level of the git repository
`sudo docker run -v $(pwd):/files -it savvybi/superset-cluster-kops:0.1`

1. From inside the superset-cluster-kops docker container, run the following
1. `/files/k8s/env-dts.sh`
1. `kubectl create -f /files/druid/postgres/postgresql.yaml`

## Deploying zookeeper - not required when deploying druid via Helm

If you have already created the k8s cluster, you will need to expand the cluster to at least 3 nodes.

From the top level of the git repository
`sudo docker run -v $(pwd):/files -it savvybi/superset-cluster-kops:0.1`

1. From inside the superset-cluster-kops docker container, run the following
1. `/files/k8s/env-dts.sh`
1. `kops edit ig nodes` and change to `maxSize: 3` and `minSize: 3`
1. Run the zookeeper deployment `kubectl apply -f /files/druid/zookeeper.yaml`

## Configuring Helm
We use [helm](http://helm.sh) to allow us to find/install and update packages to the Kubernetes cluster.

Helm acts as a package manager similar to apt-get on ubuntu or yum on redhat/centos.

Helm has two components, a client and a server.  To install/initialise helm:
From the top level of the git repository

1. `sudo docker run -v $(pwd):/files -it savvybi/superset-cluster-kops:0.1`
1. `/files/k8s/env-dts.sh`
1. Make sure the cluster is up and running: `kops validate cluster`
1. Create a serviceaccount for Tiller: `kubectl create serviceaccount tiller --namespace kube-system`
1. Apply the correct RBAC profile: `kubectl apply -f /files/helm/rbac-config.yaml`
1. `kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller`
1. Init helm `helm init`
1. `kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'`
1. Install a chart from Helm: `helm install stable/postgresql`

More charts can be found: https://hub.kubeapps.com/

## Deploying druid via Helm from local charts
From the top level of the git repository
`sudo docker run -v $(pwd):/files -it savvybi/superset-cluster-kops:0.1`

1. From inside the superset-cluster-kops docker container, run the following
1. `/files/k8s/env-dts.sh`
1. Make sure the cluster is up and running: `kops validate cluster`
1. `helm install /files/helm/druid-charts-aws-vpc-ss-dts/`

## Deploying new versions of the superset application
To deploy code from the superset github repository at: https://github.com/SavvyPlus/incubator-superset

### Build the latest image
First make sure docker is running
`sudo systemctl restart docker`

Check to see if there are any images superset-app images
`sudo docker images`

If you can see multiple versions:
```REPOSITORY                                                                        TAG                 IMAGE ID            CREATED             SIZE
547051082101.dkr.ecr.ap-southeast-2.amazonaws.com/savvybi/superset-app            5                   411c8eaac02f        7 days ago          2.18GB
547051082101.dkr.ecr.ap-southeast-2.amazonaws.com/savvybi/superset-app            production          411c8eaac02f        7 days ago          2.18GB
savvybi/superset-app                                                              5                   411c8eaac02f        7 days ago          2.18GB
547051082101.dkr.ecr.ap-southeast-2.amazonaws.com/savvybi/superset-app            4                   3c31a3ada1b5        7 days ago          2.18GB
savvybi/superset-app                                                              4                   3c31a3ada1b5        7 days ago          2.18GB
```
Then you must delete the oldest image, so you are let with just the current image tagged `production`

For example if we had the results above, then we would need to run:
`sudo docker rmi --force 3c31a3ada1b5`

If you cannot delete the image, make sure it is not being used by an active process:

`sudo docker ps -all`

When you have at most 1 superset-app image in the list returned from `sudo docker images`, you can create the new image.

1. `cd superset-app`
1. `./create-superset-image.sh`

This will build the latest version of the code from the github repository.  After the image has been built, the script will push the built image to the ECR registry.

### Deploy the latest image
From the top level of the git repository

`sudo docker run -v $(pwd):/files -it savvybi/superset-cluster-kops:0.1`

1. `/files/k8s/env-dts.sh`
1. From inside the superset-cluster-kops docker container, run the following to deploy the superset application:
`kubectl create -f /files/superset-app/superset-ss-dts.yaml`

## Destroying the Superset cluster

If you need to completely delete the cluster:
From the top level of the git repository
`sudo docker run -v $(pwd)/superset-app:/files -it savvybi/superset-cluster-kops:0.1`

1. From inside the superset-cluster-kops docker container, run the following
1. `kops export kubecfg --name=${NAME}`
1. `kops delete cluster --name ${NAME} --yes`
