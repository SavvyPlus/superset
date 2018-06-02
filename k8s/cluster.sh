# run this to create a k8s cluster in AWS

echo "Please ensure that you have already configured DNS: https://github.com/kubernetes/kops/blob/master/docs/aws.md"

echo "Please ensure that your aws account is configured with enough permissions to correctly create the kops user"

cp ~/.aws/credentials credentials

echo "Building docker image to run cluster commands - this will take some time..."
sudo docker build . -t savvybi/superset-cluster:0.1  
