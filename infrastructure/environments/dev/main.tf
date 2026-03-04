variable "aws_region" { type = string }
variable "project_name" { type = string }
variable "vpc_cidr" { type = string }
variable "azs" { type = list(string) }
variable "public_subnet_cidrs" { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }
variable "private_zone_name" { type = string }
variable "db_username" { type = string }
variable "db_password" { type = string sensitive = true }

variable "create_vpc" {
  type    = bool
  default = true
}

variable "use_remote_network_state" {
  type    = bool
  default = false

  validation {
    condition     = !(var.create_vpc && var.use_remote_network_state) && (var.create_vpc || var.use_remote_network_state)
    error_message = "Set either create_vpc=true or use_remote_network_state=true (but not both)."
  }
}

variable "network_remote_state_bucket" {
  type        = string
  default     = null
  description = "S3 bucket containing network terraform state when use_remote_network_state=true"
}

variable "network_remote_state_key" {
  type        = string
  default     = null
  description = "S3 object key for network terraform state when use_remote_network_state=true"
}

variable "network_remote_state_region" {
  type        = string
  default     = null
  description = "AWS region of S3 backend for network terraform state when use_remote_network_state=true"
}

locals {
  name = "${var.project_name}-dev"
  tags = {
    Project     = var.project_name
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

module "vpc" {
  count  = var.create_vpc ? 1 : 0
  source = "../../modules/vpc"

  name                 = local.name
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = local.tags
}

data "terraform_remote_state" "network" {
  count   = var.use_remote_network_state ? 1 : 0
  backend = "s3"

  config = {
    bucket = var.network_remote_state_bucket
    key    = var.network_remote_state_key
    region = var.network_remote_state_region
  }
}

locals {
  network_vpc_id          = var.use_remote_network_state ? data.terraform_remote_state.network[0].outputs.vpc_id : module.vpc[0].vpc_id
  network_public_subnets  = var.use_remote_network_state ? data.terraform_remote_state.network[0].outputs.public_subnet_ids : module.vpc[0].public_subnet_ids
  network_private_subnets = var.use_remote_network_state ? data.terraform_remote_state.network[0].outputs.private_subnet_ids : module.vpc[0].private_subnet_ids
}

module "iam" {
  source = "../../modules/iam"

  name = local.name
  tags = local.tags
}

module "eks" {
  source = "../../modules/eks"

  name             = "${local.name}-eks"
  cluster_version  = "1.30"
  subnet_ids       = concat(local.network_public_subnets, local.network_private_subnets)
  node_subnet_ids  = local.network_private_subnets
  cluster_role_arn = module.iam.eks_cluster_role_arn
  node_role_arn    = module.iam.eks_node_role_arn

  desired_size   = 2
  min_size       = 1
  max_size       = 4
  instance_types = ["t3.medium"]
  addons         = ["coredns", "kube-proxy", "vpc-cni", "eks-pod-identity-agent"]
  tags           = local.tags
}

module "alb_sg" {
  source = "../../modules/security-group"

  name        = "${local.name}-alb-sg"
  description = "ALB security group"
  vpc_id      = local.network_vpc_id
  ingress_rules = [{
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }]
  tags = local.tags
}

module "rds_sg" {
  source = "../../modules/security-group"

  name        = "${local.name}-rds-sg"
  description = "RDS security group"
  vpc_id      = local.network_vpc_id
  ingress_rules = [{
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }]
  tags = local.tags
}

module "alb" {
  source = "../../modules/alb"

  name               = local.name
  vpc_id             = local.network_vpc_id
  subnet_ids         = local.network_public_subnets
  security_group_ids = [module.alb_sg.security_group_id]
  tags               = local.tags
}

module "rds" {
  source = "../../modules/rds"

  name               = local.name
  db_name            = "appdb"
  username           = var.db_username
  password           = var.db_password
  subnet_ids         = local.network_private_subnets
  security_group_ids = [module.rds_sg.security_group_id]
  tags               = local.tags
}

resource "aws_route53_zone" "private" {
  name = var.private_zone_name

  vpc {
    vpc_id = local.network_vpc_id
  }

  tags = merge(local.tags, { Name = var.private_zone_name })
}

output "vpc_id" { value = local.network_vpc_id }
output "eks_cluster_name" { value = module.eks.cluster_name }
output "rds_endpoint" { value = module.rds.db_instance_endpoint }
output "alb_dns_name" { value = module.alb.alb_dns_name }
output "private_zone_id" { value = aws_route53_zone.private.zone_id }
