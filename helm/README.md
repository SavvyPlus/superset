This branch includes helm charts that need to be deployed on EKS, which is done by CodeBuild.
`buildspec.yml` is the script used by CodeBuild

Note:

1. The version of Helm client must match the version of Helm server(Tiller) installed on eks.
2. When creating the helm chart locally and updating to this branch, remember to uplaod the hidden file `.helmignore` as well