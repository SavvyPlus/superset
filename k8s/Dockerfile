FROM ubuntu:latest
MAINTAINER foamdino@gmail.com

# basic dependencies
RUN apt-get update && apt-get install -y build-essential python-dev python-pip curl wget jq vim

# install kops/kubectl & aws cli
RUN pip install --upgrade setuptools pip
RUN pip install awscli

# Kops
RUN wget -O kops https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
RUN chmod +x ./kops
RUN mv ./kops /usr/local/bin/

# Kubectl
RUN wget -O kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin/kubectl

# Kops user configuration and setup
RUN mkdir /root/.aws
COPY credentials /root/.aws/credentials
RUN mkdir /root/.ssh
RUN chmod 600 /root/.ssh
COPY id_rsa.pub /root/.ssh/id_rsa.pub
RUN chmod 600 /root/.ssh/id_rsa.pub
RUN export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id --profile kops)
RUN export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key --profile kops)

RUN aws iam create-group --group-name kops ||:
RUN aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess --group-name kops && \
  aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonRoute53FullAccess --group-name kops && \
  aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess --group-name kops && \
  aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/IAMFullAccess --group-name kops && \
  aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonVPCFullAccess --group-name kops
RUN aws iam create-user --user-name kops ||:
RUN aws iam add-user-to-group --user-name kops --group-name kops

#RUN aws s3api create-bucket --bucket savvybi-superset-state-store --region us-east-1
#RUN aws s3api put-bucket-versioning --bucket savvybi-superset-state-store  --versioning-configuration Status=Enabled

ARG CLUSTERNAME=superset.savvybi.enterprises
RUN echo $CLUSTERNAME
ENV KOPS_STATE_STORE=s3://savvybi-superset-state-store
ENV NAME=$CLUSTERNAME

RUN kops create cluster --node-size=t2.large --zones=ap-southeast-2a,ap-southeast-2b --node-count=2 --name=${NAME} ||:
RUN kops create secret --name ${NAME} sshpublickey admin -i ~/.ssh/id_rsa.pub
RUN kops update cluster ${NAME} --yes

CMD /bin/bash
