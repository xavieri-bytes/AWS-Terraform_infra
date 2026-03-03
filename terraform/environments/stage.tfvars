project_name             = "sample-app"
environment              = "stage"
aws_region               = "us-east-1"
private_hosted_zone_name = "internal.example.local"

availability_zones   = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs = ["10.1.11.0/24", "10.1.12.0/24"]

nat_gateway_mode = "single"

cluster_version                 = "1.30"
cluster_endpoint_private_access = true
cluster_endpoint_public_access  = true

node_instance_types = ["t3.large"]
node_desired_size   = 2
node_min_size       = 2
node_max_size       = 6
