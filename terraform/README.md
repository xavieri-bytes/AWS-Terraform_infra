# AWS Terraform Infrastructure Skeleton

This Terraform structure provisions:
- VPC
- Public and private subnets
- Internet Gateway
- NAT Gateway (single, per-AZ, or disabled)
- Route53 private hosted zone (associated with VPC)
- EKS cluster
- EKS worker nodes (managed node group backed by AWS Auto Scaling Group)
- EKS add-ons

## Structure

- `main.tf`: Module wiring
- `variables.tf`: Root input variables + validations
- `outputs.tf`: Root outputs
- `modules/networking`: VPC, subnets, IGW, NAT, route tables
- `modules/route53_private`: Private Route53 hosted zone
- `modules/eks`: EKS control plane + node group + IAM
- `modules/eks_addons`: EKS add-on resources

## Usage

```bash
cd terraform
terraform init
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

## Reusability Notes

- Modules are reusable because they are parameterized through input variables.
- Root variables include validation for AZ/subnet count and node scaling bounds.
- `nat_gateway_mode` supports `single`, `per_az`, and `none` patterns.
- EKS API endpoint private/public access is configurable.

- For environment-first deployments, use `infrastructure/environments/*`.

## CI

GitHub Actions workflow (`.github/workflows/terraform.yml`) runs fmt/init/validate on Terraform changes.
