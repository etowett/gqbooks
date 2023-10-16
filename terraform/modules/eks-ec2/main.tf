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
    values = ["*private*"]
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

# provider "kubernetes" {
#   host                   = module.eks.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     # This requires the awscli to be installed locally where Terraform is executed
#     args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
#   }
# }

data "aws_caller_identity" "current" {}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.17.2"

  cluster_name    = var.name
  cluster_version = var.cluster_version

  create_cni_ipv6_iam_policy = true

  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
    # vpc-cni = {
    #   most_recent              = true
    #   before_compute           = true
    #   service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
    #   configuration_values = jsonencode({
    #     env = {
    #       # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
    #       ENABLE_PREFIX_DELEGATION = "true"
    #       WARM_PREFIX_TARGET       = "1"
    #     }
    #   })
    # }
  }

  # cluster_encryption_config = [{
  #   provider_key_arn = aws_kms_key.eks.arn
  #   resources        = ["secrets"]
  # }]

  vpc_id     = data.aws_vpc.vpc.id
  subnet_ids = data.aws_subnets.private_subnet.ids

  manage_aws_auth_configmap = true

  eks_managed_node_group_defaults = {
    ami_type                   = "AL2_x86_64"
    instance_types             = var.instance_types
    iam_role_attach_cni_policy = true
    disk_size                  = 50
    # remote_access = {
    #   ec2_ssh_key               = var.ssh_key_name
    #   source_security_group_ids = [aws_security_group.remote_access.id]
    # }
  }

  eks_managed_node_groups = {
    default_node_group = {
      name            = "${var.name}-eks-default-ng"
      use_name_prefix = true

      # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
      # so we need to disable it to use the default template provided by the AWS EKS managed node group service
      use_custom_launch_template = false

      description = "EKS managed node group for ${var.name}-blue node group"
      subnet_ids  = data.aws_subnets.private_subnet.ids

      # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
      # so we need to disable it to use the default template provided by the AWS EKS managed node group service
      create_launch_template = false
      launch_template_name   = ""

      instance_types = var.instance_types
      capacity_type  = "ON_DEMAND"

      disk_size = 50

      create_launch_template = false
      launch_template_name   = ""

      update_config = {
        max_unavailable_percentage = var.max_unavailable_percentage
      }

      # Remote access cannot be specified with a launch template
      # remote_access = {
      #   ec2_ssh_key               = var.ssh_key_name
      #   source_security_group_ids = [aws_security_group.remote_access.id]
      # }

      iam_role_use_name_prefix = false
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    ingress_cluster_allow_all = {
      description                   = "Cluster to node allow all"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  tags = var.tags
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

resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = var.tags
}

resource "aws_security_group" "remote_access" {
  name        = "${var.name}-ssh-access"
  description = "Allow SSH Access to EKS ${var.name} nodes"
  vpc_id      = data.aws_vpc.vpc.id

  ingress {
    description      = "SSH From Everywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.name}-allow-tls"
  }
}
