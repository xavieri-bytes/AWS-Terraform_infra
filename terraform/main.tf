locals {
  name_prefix  = "${var.project_name}-${var.environment}"
  cluster_name = "${local.name_prefix}-eks"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )
}

module "networking" {
  source = "./modules/networking"

  name_prefix          = local.name_prefix
  cluster_name         = local.cluster_name
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  nat_gateway_mode     = var.nat_gateway_mode
  tags                 = local.common_tags
}

module "route53_private" {
  source = "./modules/route53_private"

  zone_name = var.private_hosted_zone_name
  vpc_id    = module.networking.vpc_id
  tags      = local.common_tags
}

module "eks" {
  source = "./modules/eks"

  name_prefix                     = local.name_prefix
  cluster_name                    = local.cluster_name
  cluster_version                 = var.cluster_version
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  private_subnet_ids              = module.networking.private_subnet_ids
  public_subnet_ids               = module.networking.public_subnet_ids

  node_instance_types = var.node_instance_types
  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size

  tags = local.common_tags
}

module "eks_addons" {
  source = "./modules/eks_addons"

  cluster_name = module.eks.cluster_name
  addons       = var.eks_addons
  tags         = local.common_tags
}
