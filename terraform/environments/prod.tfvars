project_name             = "sample-app"
environment              = "prod"
aws_region               = "us-east-1"
private_hosted_zone_name = "internal.example.local"

availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
public_subnet_cidrs  = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
private_subnet_cidrs = ["10.2.11.0/24", "10.2.12.0/24", "10.2.13.0/24"]

nat_gateway_mode = "per_az"

cluster_version                 = "1.30"
cluster_endpoint_private_access = true
cluster_endpoint_public_access  = false

node_instance_types = ["m5.large"]
node_desired_size   = 3
node_min_size       = 3
node_max_size       = 9
