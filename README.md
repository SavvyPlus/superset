# Jenkins X And Kubernates

This project contains basic procedures to build a CI/CD environment. The technology used here are the [kubernetes](https://kubernetes.io/)  cluster
and [Jenkins X](https://jenkins-x.io/getting-started/). They are two ways to build the environment.

1. Install Jenkins X on an existing kubernetes
2. Use [JX](https://jenkins-x.io/commands/jx/) to create the cluster as well as install Jenkins X at the same time. 

This document will focus on the first way.

## Creating the Kubernetes cluster on AWS EKS
Follow the instructions [AWS Document](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html) to create the cluster in EKS

## Install Jenkins X into the kubernetes
### Get necessary tools
Follow instuctions on https://jenkins-x.io/getting-started/install/

### Install Jenkins X
Execute command ```jx install --provider=EKS --exposer="LoadBalancer"```
Be careful with the flag `--exposer`, this flag create the entry point for Jenkins X. Without it, there is no way to access to Jenkins on the cluster.

### After installing Jenkins
Execute command ```kubectl get svc```
Find the `EXTERNAL-IP` for the service you wanna access

## Configuration on Jenkins X
The goal for CI is using Jenkins to build docker image and upload to ECR service in AWS. Since Jenkins is runing on one docker container inside Keburnetes, there are two major ways to achieve the goal:
1. Docker IN Docker  
Build the Docker Daemon inside container, together with Jenkins X, then Jenkins can execute the command of building docker image, for example `docker build ...`
2. Docker OUT OF Docker  
Use the Docker Daemon of Kubernetes Cluster. This can be configured by following steps:
Click `Manage Jenkins` > `Configure System`. On the end of this page, add a new cloud as docker cloud environment, put the Dokcer daemon link into url section.

### Pipeline in Jenkins X
There are two ways to build our superset image for pipeline.
1. Build the docker image by current script under [superset](https://github.com/SavvyPlus/superset.git) project. The scirpt will clone the `incubator-superset` every time, and compile them as a image, then it will upload the image into Oregon ECR. This is not a good practice for CI
2. Build the docker image by command inside pipeline. Then it can control every tiny step for intergration, such as only pull new code from github but not clone the whole repo.


In order to acheive it in a faster way, the sample code for new Pipeline select the first way to build the project.
```
pipeline {
    agent any
    stages {
        stage('Build') {            
            steps {                
                 script {
                 docker.withTool('docker_jx') {
                   sh '''
                        #!/bin/bash -ilex
                        cd superset-app
                        ./create-superset-image.sh
                    '''
                 }
               }
            }        
        }        
        stage('Test') {            
            steps {                
                echo 'Testing'            
            }        
        }
        stage('Deploy - Staging') {            
            steps {                
                echo 'deploy'
            }        
        }        
        stage('Sanity check') {            
            steps {                
                input "Does the staging environment look ok?"            
            }        
        }        
        stage('Deploy - Production') {            
            steps {                
                sh './deploy production'            
            }        
        }    
    }
 
    post {        
        always {            
            echo 'One way or another, I have finished'            
            deleteDir() /* clean up our workspace */        
        }        
        success {            
            echo 'I succeeeded!'        
        }        
        unstable {            
            echo 'I am unstable :/'        
        }        
        failure {            
            echo 'I failed :('        
        }        
        changed {            
            echo 'Things were different before...'        
        }    
    }
}
```
Note that `./create-superset-image.sh` Script should be executed inside `docker.withTool`. The `docker_jx` is configured in `Global Tool Configuration`.