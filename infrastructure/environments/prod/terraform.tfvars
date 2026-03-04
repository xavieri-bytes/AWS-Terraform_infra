aws_region            = "us-east-1"
project_name          = "platform"
vpc_cidr              = "10.30.0.0/16"
azs                   = ["us-east-1a", "us-east-1b", "us-east-1c"]
public_subnet_cidrs   = ["10.30.1.0/24", "10.30.2.0/24", "10.30.3.0/24"]
private_subnet_cidrs  = ["10.30.11.0/24", "10.30.12.0/24", "10.30.13.0/24"]
private_zone_name     = "prod.internal.local"
db_username           = "dbadmin"
db_password           = "ChangeMeStrongPassword123!"

create_vpc                = true
use_remote_network_state  = false

# When use_remote_network_state = true, set these:
# network_remote_state_bucket = "my-terraform-state-bucket"
# network_remote_state_key    = "infrastructure/network/terraform.tfstate"
# network_remote_state_region = "us-east-1"
