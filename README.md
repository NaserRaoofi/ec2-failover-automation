# EC2 Failover Automation

A modular Terraform project for creating AWS services with automated failover capabilities.

## Project Structure

```
.
├── modules/                 # Reusable Terraform modules
│   ├── ec2/                # EC2 instance module
│   ├── networking/         # VPC, subnets, security groups
│   ├── load_balancer/      # Application Load Balancer
│   └── monitoring/         # CloudWatch, SNS
├── environments/           # Environment-specific configurations
│   ├── dev/
│   ├── staging/
│   └── prod/
├── scripts/               # Helper scripts
└── docs/                  # Documentation
```

## Prerequisites

- AWS CLI configured
- Terraform >= 1.0
- Proper IAM permissions

## Usage

1. Navigate to the desired environment directory
2. Initialize Terraform: `terraform init`
3. Plan deployment: `terraform plan`
4. Apply changes: `terraform apply`

## Features

- Multi-AZ deployment for high availability
- Automated failover mechanisms
- Modular design for reusability
- Environment-specific configurations
- Monitoring and alerting

## Getting Started

See the documentation in the `docs/` directory for detailed setup instructions.
