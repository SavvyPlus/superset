# Run this in the docker container to export correct env to kubecfg
export KOPS_STATE_STORE=s3://savvybi-superset-dts-state-store
export NAME=aws2-vpc-ss-dts.savvybi.enterprises
kops export kubecfg --name=${NAME}
