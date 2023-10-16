variable "name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "env" {
  type = string
}

variable "cluster_endpoint_private_access" {
  type    = bool
  default = true
}

variable "cluster_endpoint_public_access" {
  type    = bool
  default = true
}

variable "subnet_filter" {
  type    = string
  default = "private"
}

# variable "instance_types" {
#   type = list(string)
# }

variable "azs" {
  type = list(string)
}

# variable "ssh_key_name" {
#   type = string
# }

# variable "desired_size" {
#   type = number
# }

# variable "min_size" {
#   type = number
# }

# variable "max_size" {
#   type = number
# }

# variable "max_unavailable_percentage" {
#   type    = number
#   default = 50
# }

variable "tags" {
  type = map(any)
}
