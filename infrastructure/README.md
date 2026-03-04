# Infrastructure Terraform Layout

This structure matches environment-first deployment with reusable modules:

- `modules/vpc`: VPC, subnets, IGW, NAT, route tables
- `modules/eks`: EKS cluster, managed node group (ASG-backed), EKS add-ons
- `modules/rds`: PostgreSQL RDS instance + subnet group
- `modules/alb`: Application Load Balancer + target group + listener
- `modules/security-group`: Reusable SG module
- `modules/iam`: IAM roles for EKS cluster and node groups
- `environments/dev|stage|prod|uat`: per-environment entry points
- `global/shared-services`: shared global services placeholder

## Example usage

```bash
cd infrastructure/environments/dev
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```


## Remote state integration

Environment stacks support reading VPC/subnet outputs from remote state using `data "terraform_remote_state"` (S3 backend).
Set `create_vpc=false` and `use_remote_network_state=true`, then provide `network_remote_state_bucket`, `network_remote_state_key`, and `network_remote_state_region` in `terraform.tfvars`.
