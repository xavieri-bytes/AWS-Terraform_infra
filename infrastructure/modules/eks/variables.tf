variable "name" { type = string }
variable "cluster_version" { type = string }
variable "subnet_ids" { type = list(string) }
variable "node_subnet_ids" { type = list(string) }
variable "cluster_role_arn" { type = string }
variable "node_role_arn" { type = string }
variable "desired_size" { type = number }
variable "min_size" { type = number }
variable "max_size" { type = number }
variable "instance_types" { type = list(string) }
variable "addons" { type = list(string) default = ["coredns", "kube-proxy", "vpc-cni"] }
variable "tags" { type = map(string) default = {} }
