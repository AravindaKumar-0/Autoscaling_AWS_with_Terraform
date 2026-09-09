## Architecture
<img width="1476" height="1203" alt="Terraform AWS CICD Architecture Pipeline(1)" src="https://github.com/user-attachments/assets/3dfa0d18-06fe-44e9-92ba-abc154212d88" />

- **VPC** spanning 3 Availability Zones (10.0.0.0/16) with public and private subnet tiers
- **Public subnets**: Application Load Balancer (multi-AZ), Bastion Host (SSH admin access), NAT Gateway (outbound egress for private subnet)
- **Private subnets**: Auto Scaling Group running application instances, never directly exposed to the internet
- **IAM**: least-privilege instance role attached via instance profile (CloudWatch access only)
- **Remote state**: S3 backend with native state locking, no local state ever committed

## Tech Stack

| Layer | Tool/Tech |
|---|---|
| IaC | Terraform (modular: vpc, security-groups, alb, autoscaling) |
| CI/CD orchestration | Jenkins (declarative pipeline) |
| Cloud provider | AWS (VPC, EC2, ALB, ASG, IAM) |
| State management | S3 remote backend with native locking |
| Scaling | Target-tracking policy (70% avg CPU), rolling instance refresh |

## Repository Structure

\```
.
├── modules/
│   ├── vpc/
│   ├── security-groups/
│   ├── alb/
│   └── autoscaling/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── versions.tf
├── Jenkinsfile
└── .gitignore
\```

## Pipeline Stages

1. **Checkout** — pulls Terraform code from GitHub
2. **Terraform Init** — initializes providers and remote S3 backend
3. **Format Check** — `terraform fmt -check` enforces canonical style
4. **Validate** — syntax and internal consistency check
5. **Select Action** — choose APPLY or DESTROY via pipeline parameter
6. **Plan** — generates and archives a saved plan file
7. **Approval Gate** — manual human approval before any change is applied
8. **Apply / Destroy** — applies the exact saved plan, never a re-computed one

## Security Considerations

- App tier lives entirely in private subnets — never directly internet-reachable
- Security groups are layered: ALB accepts internet traffic, app instances only accept traffic from the ALB's security group and SSH only from the bastion's security group
- Bastion SSH is restricted to a configurable CIDR (your IP), not open to the world
- IAM role follows least-privilege — scoped only to CloudWatch access, not broad EC2/S3 permissions
- No secrets or state files are committed — remote state lives in an encrypted S3 backend, credentials are injected via Jenkins credential binding

## Setup / Run

\```bash
# 1. Clone
git clone https://github.com/AravindaKumar-0/Autoscaling_AWS_with_Terraform.git

# 2. Set your own values
# Edit terraform.tfvars: set bastion_allowed_cidr to your IP, set key_name if using SSH

# 3. Initialize and review
terraform init
terraform fmt -check
terraform validate
terraform plan

# 4. Apply
terraform apply
\```

## Outputs

- `alb_dns_name` — public URL to access the load-balanced application
- `bastion_public_ip` — SSH entry point for admin access
- `autoscaling_group_name` — for monitoring/scaling verification
- `vpc_id` — for reference in other infra

## Cleanup

\```bash
terraform destroy
\```
