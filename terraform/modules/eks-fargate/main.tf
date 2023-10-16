data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnets" "private_subnet" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*${var.subnet_filter}*"]
  }
}

data "aws_subnets" "public_subnet" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
}

data "aws_caller_identity" "current" {}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.17.2"

  cluster_name    = var.name
  cluster_version = var.cluster_version

  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access

  cluster_addons = {
    kube-proxy = {}
    vpc-cni    = {}
    coredns = {
      configuration_values = jsonencode({
        computeType = "Fargate"
      })
    }
  }

  vpc_id                   = data.aws_vpc.vpc.id
  subnet_ids               = data.aws_subnets.private_subnet.ids
  control_plane_subnet_ids = data.aws_subnets.public_subnet.ids

  # Fargate profiles use the cluster primary security group so these are not utilized
  create_cluster_security_group = false
  create_node_security_group    = false

  fargate_profile_defaults = {
    iam_role_additional_policies = {
      additional = aws_iam_policy.additional.arn
    }
  }

  fargate_profiles = merge(
    {
      main = {
        name = "main"
        selectors = [
          {
            namespace = "backend"
            labels = {
              Application = "backend"
            }
          },
          {
            namespace = "app-*"
            labels = {
              Application = "app-wildcard"
            }
          }
        ]

        # Using specific subnets instead of the subnets supplied for the cluster itself
        subnet_ids = data.aws_subnets.private_subnet.ids

        tags = {
          Owner = "secondary"
        }

        timeouts = {
          create = "20m"
          delete = "20m"
        }
      }
    },
    { for i in range(2) :
      "kube-system-${element(split("-", var.azs[i]), 2)}" => {
        selectors = [
          { namespace = "kube-system" }
        ]
        # We want to create a profile per AZ for high availability
        subnet_ids = [element(data.aws_subnets.private_subnet.ids, i)]
      }
    }
  )

  tags = var.tags
}

resource "aws_iam_policy" "additional" {
  name = "${var.name}-additional"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# module "vpc_cni_irsa" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#   version = "~> 5.0"

#   role_name_prefix      = "VPC-CNI-IRSA"
#   attach_vpc_cni_policy = true
#   vpc_cni_enable_ipv6   = true

#   oidc_providers = {
#     main = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = ["kube-system:aws-node"]
#     }
#   }

#   tags = var.tags
# }

# resource "aws_kms_key" "eks" {
#   description             = "EKS Secret Encryption Key"
#   deletion_window_in_days = 7
#   enable_key_rotation     = true

#   tags = var.tags
# }

# resource "aws_security_group" "remote_access" {
#   name        = "${var.name}-ssh-access"
#   description = "Allow SSH Access to EKS ${var.name} nodes"
#   vpc_id      = data.aws_vpc.vpc.id

#   ingress {
#     description      = "SSH From Everywhere"
#     from_port        = 22
#     to_port          = 22
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   tags = {
#     Name = "${var.name}-allow-tls"
#   }
# }
