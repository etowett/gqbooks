terraform {
  backend "s3" {
    bucket = "ello-terraform-state"
    key    = "live/statefile.json"
    region = "eu-central-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = local.region
}

locals {
  env     = "live"
  project = "ello"
  region  = "eu-central-1"
  azs     = ["${local.region}a", "${local.region}b"]
}

module "vpc" {
  source = "../..//modules/vpc"

  name = "${local.env}-${local.project}-net"
  cidr = "10.20.0.0/16"
  env  = local.env

  enable_nat_gateway = true
  enable_vpn_gateway = false
  enable_dns_support = true

  azs             = local.azs
  private_subnets = ["10.20.1.0/24", "10.20.2.0/24"]
  public_subnets  = ["10.20.3.0/24", "10.20.4.0/24"]

  database_subnets = []
}

module "eks-fargate" {
  source = "../..//modules/eks-fargate"

  env             = local.env
  name            = "${local.env}-${local.project}-cluster"
  cluster_version = "1.28"
  vpc_name        = "${local.env}-${local.project}-net"

  azs = ["${local.region}a", "${local.region}b"]

  tags = {
    "Name"      = "${local.env}-cluster"
    "Env"       = local.env
    "ManagedBy" = "terraform"
  }

  depends_on = [module.vpc]
}
