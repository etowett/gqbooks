terraform {
  backend "s3" {
    bucket = "spinmobile-terraform-state"
    key    = "fiddle/tfello.json"
    region = "eu-west-1"
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
  env     = "stage"
  project = "ello"
  region  = "eu-central-1"
  azs     = ["${local.region}a", "${local.region}b"]

  apps = {
    "gqbooks"   = { "port" : 7080 }
    "gqbooksui" = { "port" : 80 }
  }
}

module "vpc" {
  source = "../..//modules/vpc"

  name = "${local.env}-${local.project}-net"
  cidr = "10.10.0.0/16"
  env  = local.env

  enable_nat_gateway = true
  enable_vpn_gateway = false
  enable_dns_support = true

  azs             = local.azs
  private_subnets = ["10.10.1.0/24", "10.10.2.0/24"]
  public_subnets  = ["10.10.3.0/24", "10.10.4.0/24"]

  database_subnets = []
}

# module "eks-fargate" {
#   source = "../..//modules/eks-fargate"

#   env             = local.env
#   name            = "${local.env}-${local.project}-cluster"
#   cluster_version = "1.28"
#   vpc_name        = "${local.env}-${local.project}-net"

#   azs = ["${local.region}a", "${local.region}b"]

#   tags = {
#     "Name"      = "${local.env}-cluster"
#     "Env"       = local.env
#     "ManagedBy" = "terraform"
#   }

#   depends_on = [module.vpc]
# }

# # module "eks-ec2" {
# #   source = "../..//modules/eks-ec2"

# #   env             = local.env
# #   name            = "${local.env}-${local.project}-clstr"
# #   cluster_version = "1.27"
# #   vpc_name        = "${local.env}-${local.project}-net"

# #   instance_types = ["t3.small", "t3a.small"]
# #   ssh_key_name   = "id_spinmobile_main"

# #   desired_size = 1
# #   min_size     = 1
# #   max_size     = 3

# #   tags = {
# #     "name"       = "${local.env}-ec2-cluster"
# #     "env"        = local.env
# #     "managed_by" = "terraform"
# #   }
# # }

# resource "aws_ecr_repository" "app_ecr_repo" {
#   for_each = local.apps
#   name     = each.key
# }
