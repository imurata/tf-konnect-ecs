# Kong Gateway Data Plane on AWS ECS (Fargate) with Terraform

This project contains Terraform code to deploy Kong Gateway (Data Plane) on AWS ECS (Fargate).
It integrates with Konnect Control Plane and handles automatic certificate generation and registration.

## File Structure

```text
.
├── alb.tf              # Application Load Balancer (ALB), Target Group, Listener
├── cloudwatch.tf       # CloudWatch Log Group (for ECS logs)
├── ecs.tf              # ECS Cluster, Task Definition, Service
├── env.sh              # Environment variable configuration file (excluded from git)
├── iam.tf              # ECS Task Execution Role
├── konnect.tf          # Konnect integration (Control Plane lookup, Certificate generation/registration)
├── outputs.tf          # Output definitions (ALB DNS name, etc.)
├── providers.tf        # Terraform Provider settings (AWS, Konnect, TLS)
├── run.sh              # Execution script
├── security_groups.tf  # Security Groups (for ALB, ECS Tasks)
├── variables.tf        # Variable definitions
└── vpc.tf              # VPC, Subnet, Internet Gateway, Route Table
```

## File Overview

- **alb.tf**: Defines the Load Balancer accepting external access. Health checks are performed on `/status/ready` (port 8100).
- **cloudwatch.tf**: Defines the log group `/ecs/kong-dp` for storing ECS task logs.
- **ecs.tf**: Defines the Fargate Task and Service for running Kong Gateway. Connection settings for Konnect are injected as environment variables.
- **iam.tf**: Defines IAM roles for ECS tasks to send logs and pull images.
- **konnect.tf**: Uses the Konnect Provider to dynamically generate a client certificate for the Data Plane and register it with Konnect.
- **security_groups.tf**:
    - For ALB: Allows HTTP (80) from specified CIDRs (default is specific IP only).
    - For ECS Tasks: Allows traffic only from ALB (8000, 8100).
- **vpc.tf**: Builds the VPC network environment for the application.
- **variables.tf**: Defines project-wide variables (Region, App Name, CIDR, etc.).

## Usage

### 1. Prerequisites
- Terraform installed
- AWS CLI configured (e.g., `aws configure`)
- Konnect account and Personal Access Token (PAT)

### 2. Configure Environment Variables
Create (or edit) the `env.sh` file and set your Konnect PAT.

Also, the Security Group restricts inbound traffic to a specific IP by default. You must configure it to allow access from your client's IP address.

```bash
# env.sh
export TF_VAR_konnect_personal_access_token="your_konnect_pat_here"

# Set your IP address (CIDR format) to allow access to the ALB
# Example: export TF_VAR_allowed_cidr_blocks='["203.0.113.1/32"]'
export TF_VAR_allowed_cidr_blocks='["YOUR_IP_ADDRESS/32"]'
```

### 3. Execution

Use the included script to manage the infrastructure lifecycle.

```bash
chmod +x run.sh

# Start (Init & Apply)
./run.sh start

# Stop (Destroy)
./run.sh stop
```

The script performs the following steps:
- `start`: Loads environment variables, runs `terraform init`, and then `terraform apply`.
- `stop`: Loads environment variables and runs `terraform destroy`.

### 4. Verification
After `terraform apply` completes, access the output ALB DNS name to verify operation.

```bash
curl http://<alb_dns_name>/
```
