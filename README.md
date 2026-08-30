# Production-Grade Multi-AZ AWS Platform (Terraform)

A highly available, security-hardened AWS infrastructure built entirely with Terraform — designed to survive a full Availability Zone outage with zero downtime, and to eliminate common production security gaps (public SSH, exposed backend workloads) from day one.

The platform hosts a scalable web application (Nginx app tier) backed by a Multi-AZ PostgreSQL database, fronted by CloudFront/WAF for global delivery and edge protection.

## 🚀 Key Engineering Highlights

* **High Availability & Fault Tolerance:** Deployed across multiple Availability Zones with an Auto Scaling Group (ASG) for the compute tier and a Multi-AZ deployment for the RDS database, ensuring seamless failover.
* **Zero-Trust Network Segmentation:** Eliminated public exposure for backend workloads by placing EC2 instances in private application subnets, utilizing a NAT Gateway for outbound traffic, and routing all external access strictly through a public-facing Application Load Balancer (ALB).
* **Bastion-less Secure Access:** Removed inbound SSH (`Port 22`) exposure entirely. Remote access is brokered through **EC2 Instance Connect Endpoint (EICE)** and **AWS Systems Manager (SSM)** — no bastion host, no distributed SSH keys.
* **Advanced Security & Edge Protection:**
  * Integrated **AWS WAF** to protect against common web exploits (SQLi, XSS).
  * TLS termination and global asset delivery via **Amazon CloudFront** and **AWS Certificate Manager (ACM)**.
* **Engine-Agnostic Database Layer:** RDS module is parameterized by engine, version, and parameter group family — the database currently runs PostgreSQL, but switching engines doesn't require rewriting resources. ( you can change it from variables.tf )
* **Observability:** CloudWatch alarms (CPU utilization, instance status checks) wired to SNS for automated notification.
* **Data Durability:** Automated RDS backups and deletion-protection safeguards to prevent accidental data loss.
* **Infrastructure as Code (IaC):** 100% declarative provisioning using Terraform, maintaining reproducibility and version-controlled environments.

## 🧠 What This Project Demonstrates

* Designing for **failure scenarios** (AZ outage, instance failure) rather than just the happy path
* Applying **zero-trust principles** to network architecture — no standing SSH access, no public backend exposure
* Structuring Terraform the way production teams do: modular, incrementally hardened, and version-controlled from the first commit
* Understanding the **shared responsibility model** in practice — securing the infrastructure layer so the application layer isn't carrying that risk alone

## 🛠️ Tech Stack

| Category | Services |
|---|---|
| Provisioning | Terraform (HCL) |
| Networking | VPC, Public/Private Subnets, Internet Gateway, NAT Gateway, Route Tables |
| Compute | EC2, Launch Template, Auto Scaling Group |
| Load Balancing | Application Load Balancer, Target Groups, Health Checks |
| Database | Amazon RDS (Multi-AZ, engine-agnostic) |
| Security | AWS WAF, Security Groups, IAM (least privilege), ACM |
| Access | EC2 Instance Connect Endpoint (EICE), AWS Systems Manager (SSM), VPC Interface Endpoints |
| Delivery | Amazon CloudFront |
| Observability | CloudWatch Alarms, SNS |
| Web Server | Nginx |

## 🔒 Security Groups

| Security Group | Inbound | Outbound |
|---|---|---|
| `alb_sg` | HTTP/HTTPS from `0.0.0.0/0` | All traffic |
| `app_sg` | HTTP from `alb_sg` only | All traffic |
| `db_sg` | DB port from `app_sg` only | All traffic |
| `connectivity_sg` | EICE/VPC Endpoint traffic scoped to VPC CIDR | All traffic |

## 📂 Repository Structure

```text
infrastructure/
├── providers.tf    # Terraform + AWS provider configuration
├── variables.tf    # Region, CIDR blocks, and other input variables
├── vpc.tf          # VPC, subnets, route tables, IGW, NAT Gateway
├── main.tf         # 
├── compute.tf      # Launch Template, Auto Scaling Group, EICE, VPC endpoints
├── lb.tf           # Application Load Balancer, target group, listener
├── database.tf     # RDS instance, subnet group, parameter group (engine-agnostic)
├── cdn.tf          # CloudFront distribution configuration
├── security.tf     # WAF configuration,Security groups, IAM roles/policies
├── monitoring.tf   # CloudWatch alarms wired to the SNS topic
└── outputs.tf      # ALB DNS name and other exported values
```

## ⚙️ Prerequisites

* Terraform >= 1.5.0
* An AWS account with credentials configured (`aws configure` or environment variables)
* Appropriate IAM permissions to provision VPC, EC2, RDS, ALB, WAF, and CloudFront resources

## 🚀 Deployment

1. Clone the repository:
```bash
git clone https://github.com/z5amr/production-grade-multi-az-aws-platform-terraform.git
cd production-grade-multi-az-aws-platform-terraform/infrastructure
```

2. Initialize Terraform:
```bash
terraform init
```

3. Review the execution plan:
```bash
terraform plan
```

4. Apply the infrastructure:
```bash
terraform apply                     # It may take several minuts
```

> **Note:** This provisions billable AWS resources. Review `variables.tf` before applying.

### Destroy

```bash
terraform destroy                 # Consider destroy if using for expermental reasons not real workload for not drainig your money
```

> **Note:** RDS has deletion-protection safeguards enabled. You may need to disable `deletion_protection` and/or take a final snapshot before `terraform destroy` will succeed.

## 🔧 Key Variables

| Variable | Description | Default |
|---|---|---|
| `aws_region` | AWS region for deployment | `us-east-1` |
| `vpc_cidr` | CIDR block for the VPC | `10.0.0.0/16` |
| `public_subnet_cidr_a` / `_b` | Public subnet CIDRs (AZ-A / AZ-B) | `10.0.1.0/24` / `10.0.2.0/24` |
| `private_app_subnet_cidr_a` / `_b` | Private app subnet CIDRs | `10.0.10.0/24` / `10.0.11.0/24` |
| `private_db_subnet_cidr_a` / `_b` | Private DB subnet CIDRs | `10.0.20.0/24` / `10.0.21.0/24` |
| `db_engine`, `db_engine_version`, `db_family` | Engine-agnostic RDS configuration | — |

## 🗺️ Build Progression

This project was built incrementally, mirroring how infrastructure typically hardens over time in a real environment:

1. VPC and public subnet provisioning
2. EC2 web server with public SSH access (initial baseline - changed later)
3. Migration to Auto Scaling Group + Application Load Balancer
4. Transition to private subnets with NAT Gateway routing
5. Zero-trust access: VPC Interface Endpoints (SSM family) + EC2 Instance Connect Endpoint, removing the need for a bastion host or exposed SSH keys
6. Multi-AZ expansion for the database tier
7. Observability layer (CloudWatch + SNS)
8. Engine-agnostic RDS refactor
9. Data durability: automated backups + deletion protection
10. Security & global delivery layer: ACM, WAF, CloudFront

## License

MIT License — see [LICENSE](./LICENSE) for details.
