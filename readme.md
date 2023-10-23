# GQBooks

Graphql books library.

This project is composed of a golang graphql backend and vuejs frontend. The UI is hosted in the `web` directory.

To run the application locally:

First ensure that you have golang installed locally and you have the go command available. Then download the dependencies by running `go mod download` at the base of the project.

Compile the application using this command:

```sh
go build -o ./gqbooks .
```

Then run

```sh
./gqbooks
```

If it is successful, you should see an output similar to this

```sh
$ ./gqbooks
2023/10/23 10:24:08 connect to http://localhost:7080/ for GraphQL playground
```

Next, in a separate terminal window, switch to the `web` directory and run `npm run dev` to start the frontend.

Access the frontend using the URL `http://localhost:5173`.

## Building and running live

This code also has terraform code to provision an AWS infrastructure to run the application. In the terraform directory, the `envs` directory will contain stage specific configurations for managing the infrastructure.

With an AWS Iam user with the correct credentials, you can manage changes to the environment.

The code creates a virtual private network (VPC) with public and private subnets in two availability zones. It then creates a kubernetes cluster with fargate prifile.

Use these commands to create:

```sh
cd terraform/envs/stage
terraform init
terraform plan
terraform apply
```

There is a github pipeline action in the `.github/workflows/build-tf.yaml` that will plan and apply terraform changes.

Check more information about accessing and working with the cluster [here](./docs/k8s.md).

## Building and deploying application

There are github actions workflows to build and deploy both the backend and frontend.

- [Deploy Backend in EKS](.github/workflows/build-deploy-backend.yaml)
- [Deploy Frontend in EKS](.github/workflows/build-deploy-ui.yaml)
