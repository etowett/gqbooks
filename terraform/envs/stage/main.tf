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
}

module "vpc" {
  source = "../..//modules/vpc"

  name = "${local.env}-${local.project}-net"
  cidr = "10.10.0.0/16"
  env  = local.env

  enable_nat_gateway = false
  enable_vpn_gateway = false
  enable_dns_support = true

  azs             = ["${local.region}a", "${local.region}b", ]
  private_subnets = ["10.10.1.0/24", "10.10.2.0/24"]
  public_subnets  = ["10.10.3.0/24", "10.10.4.0/24"]

  database_subnets = []
}

resource "aws_ecr_repository" "app_ecr_repo" {
  name = "ellorepo"
}
