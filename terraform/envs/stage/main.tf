terraform {
  backend "s3" {
    bucket = "spay-infra-store"
    key    = "terraform/ello"
    region = "eu-west-1"
  }

  #   required_providers {
  #     aws = {
  #       source  = "hashicorp/aws"
  #       version = "5.17.0"
  #     }
  #   }
}

provider "aws" {
  region = local.region
}

locals {
  env     = "stage"
  project = "ello"
  region  = "eu-central-1"
  azs     = ["${local.region}a", "${local.region}b"]
}

module "vpc" {
  source = "../..//modules/vpc"

  name = "${local.env}-${local.project}-net"
  cidr = "10.10.0.0/16"
  env  = local.env

  enable_nat_gateway = false
  enable_vpn_gateway = false
  enable_dns_support = true

  azs             = local.azs
  private_subnets = ["10.10.1.0/24", "10.10.2.0/24"]
  public_subnets  = ["10.10.3.0/24", "10.10.4.0/24"]

  database_subnets = []
}

module "eks" {
  source = "../..//modules/eks"

  env             = local.env
  name            = "${local.env}-${local.project}-cluster"
  cluster_version = "1.28"
  vpc_name        = "${local.env}-${local.project}-net"
  # ssh_key_name    = "id_spay_main"

  # instance_types = ["t3.small", "t3a.small"]
  azs = ["${local.region}a", "${local.region}b"]

  # desired_size = 1
  # min_size     = 1
  # max_size     = 3

  tags = {
    "Name"      = "${local.env}-cluster"
    "Env"       = local.env
    "ManagedBy" = "terraform"
  }
}
