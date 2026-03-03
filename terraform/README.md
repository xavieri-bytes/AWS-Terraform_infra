# AWS Terraform Infrastructure Skeleton

This Terraform structure provisions:
- VPC
- Public and private subnets
- Internet Gateway
- NAT Gateway
- Route53 private hosted zone (associated with VPC)
- EKS cluster
- EKS worker nodes (managed node group backed by AWS Auto Scaling Group)
- EKS add-ons

## Structure

- `main.tf`: Module wiring
- `variables.tf`: Root input variables
- `outputs.tf`: Root outputs
- `modules/networking`: VPC, subnets, IGW, NAT, route tables
- `modules/route53_private`: Private Route53 hosted zone
- `modules/eks`: EKS control plane + node group + IAM
- `modules/eks_addons`: EKS add-on resources

## Usage

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

> Update `terraform.tfvars` values (CIDRs, AZs, names) before apply.
