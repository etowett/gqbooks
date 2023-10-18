# Once kubernetes is created

You need to be granted access to AWS with the right permissions.

You need kubectl installed before proceeding. Install kubectl [here](https://kubernetes.io/docs/tasks/tools/).

Install [aws cli here](https://aws.amazon.com/cli/).

Generate Credentials

Create a file `~/.aws/credentials` in home directory and add the credentials

```config
[ello]
aws_access_key_id = xxx
aws_secret_access_key = xxxx
aws_region = eu-central-1
aws_default_region = eu-central-1
```

Then in the terminal, to use the credentials, export

```sh
export AWS_PROFILE=ello
```

Confirm

```sh
aws sts get-caller-identity
```

Create s3 terraform state bucket

```sh
aws s3api create-bucket \
    --bucket citizix-infra-bkt \
    --region eu-central-1 \
    --create-bucket-configuration LocationConstraint=eu-central-1

aws s3api put-bucket-encryption \
    --bucket citizix-infra-bkt \
    --server-side-encryption-configuration "{\"Rules\": [{\"ApplyServerSideEncryptionByDefault\":{\"SSEAlgorithm\": \"AES256\"}}]}"

aws s3api put-bucket-versioning \
    --bucket citizix-infra-bkt \
    --versioning-configuration Status=Enabled
```

in the staging directory, run terraform commands:

```sh
cd terraform/envs/stage

terraform init

terraform plan
```

List eks clusters

```sh
aws eks list-clusters --region=eu-central-1
```

Then update kubeconfig

```sh
aws eks update-kubeconfig --region eu-central-1 --name stage-ec2-cluster
```

Confirm connectivity

List nodes

```sh
kubectl get no -o wide
```

Check kubernetes version

```sh
kubectl version
```

You should see something similar to this

```sh
$ kubectl version

Client Version: v1.28.2
Kustomize Version: v5.0.4-0.20230601165947-6ce0bf390ce3
Server Version: v1.28.2-eks-f8587cb
```

## Helm

```sh
helm create app
```
