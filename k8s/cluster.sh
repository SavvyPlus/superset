# run this to create a k8s cluster in AWS

CLUSTERNAME=$1
if [ -z "${CLUSTERNAME:+x}" ]; then
  echo "CLUSTERNAME not set, using demo.zawee.io";
  CLUSTERNAME=demo.zawee.io
else
  echo "CLUSTERNAME set to '$CLUSTERNAME'";
fi

echo "Please ensure that you have already configured DNS: https://github.com/kubernetes/kops/blob/master/docs/aws.md"
read -p "Press any key to continue... " -n1 -s
echo

echo "Please ensure that your aws account is configured with enough permissions to correctly create the kops user"
read -p "Press any key to continue... " -n1 -s
echo

echo "Creating s3 bucket for cluster store..."
aws s3api create-bucket --bucket demo-zawee-io-state-store --region ap-southeast-2 --create-bucket-configuration LocationConstraint=ap-southeast-2 
aws s3api put-bucket-versioning --bucket demo-zawee-io-state-store  --versioning-configuration Status=Enabled
aws s3api put-bucket-encryption --bucket demo-zawee-io-state-store --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

cp ~/.aws/credentials credentials
cp ~/.ssh/id_rsa.pub id_rsa.pub

echo "Building docker image to run cluster commands - this will take some time..."
echo "clustername: ${CLUSTERNAME}"
sudo docker build . -t savvybi/superset-cluster-kops:0.1 --build-arg CLUSTERNAME=${CLUSTERNAME}

echo "Running cluster commands in new container..."
export KOPS_STATE_STORE=s3://demo-zawee-io-state-store
export NAME=$CLUSTERNAME
sudo docker run savvybi/superset-cluster-kops:0.1
