# Getting Started Guide

## Prerequisites

Before you begin, ensure you have the following installed and configured:

1. **AWS CLI** - [Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
2. **Terraform** (>= 1.0) - [Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)
3. **Git** - [Installation Guide](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

## AWS Configuration

1. Configure AWS credentials:
   ```bash
   aws configure
   ```

2. Verify your AWS credentials:
   ```bash
   aws sts get-caller-identity
   ```

## Quick Start

### 1. Clone the Repository

```bash
git clone git@github.com:NaserRaoofi/ec2-failover-automation.git
cd ec2-failover-automation
```

### 2. Configure Environment Variables

```bash
cd environments/dev
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your desired configuration:

```hcl
# General Configuration
aws_region   = "us-east-1"
project_name = "ec2-failover-dev"
environment  = "dev"

# EC2 Configuration
instance_type    = "t3.micro"
key_name         = "your-key-pair-name"  # Optional
min_size         = 1
max_size         = 3
desired_capacity = 2

# Monitoring Configuration
alert_email_addresses = ["your-email@example.com"]
```

### 3. Deploy the Infrastructure

Option A: Using the deployment script (recommended):
```bash
./scripts/deploy.sh dev
```

Option B: Manual deployment:
```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

### 4. Access Your Application

After deployment, Terraform will output:
- **Application URL**: Access your load-balanced application
- **Dashboard URL**: View CloudWatch metrics and monitoring

## Architecture Overview

The infrastructure creates:

- **VPC** with public and private subnets across multiple AZs
- **Application Load Balancer** for traffic distribution
- **Auto Scaling Group** with EC2 instances in private subnets
- **CloudWatch monitoring** with alarms and dashboards
- **SNS notifications** for alerts

## Testing Failover

1. **Simulate instance failure**:
   ```bash
   # Terminate an instance through AWS Console or CLI
   aws ec2 terminate-instances --instance-ids i-1234567890abcdef0
   ```

2. **Monitor Auto Scaling**:
   - Check CloudWatch dashboard
   - Verify new instance launches automatically
   - Test application availability during failover

## Monitoring and Alerts

The system includes several CloudWatch alarms:

- **High Response Time**: Triggers when ALB response time > 1 second
- **High 4xx Errors**: Triggers when 4xx errors > 10 in 5 minutes
- **High 5xx Errors**: Triggers when 5xx errors > 5 in 5 minutes
- **Unhealthy Targets**: Triggers when healthy targets < 1

## Scaling Configuration

Auto Scaling is configured with:
- **CPU-based scaling**: Scale up at 80% CPU, scale down at 10% CPU
- **Customizable thresholds**: Modify in module variables
- **Multi-AZ deployment**: Instances distributed across availability zones

## Cleanup

To destroy the infrastructure:

```bash
./scripts/cleanup.sh dev
```

Or manually:
```bash
cd environments/dev
terraform destroy
```

## Troubleshooting

### Common Issues

1. **AWS Credentials**: Ensure AWS CLI is configured with proper permissions
2. **Key Pair**: If using SSH, ensure the key pair exists in your AWS region
3. **Resource Limits**: Check AWS service limits for your account
4. **VPC Limits**: Ensure you haven't exceeded VPC limits in your region

### Useful Commands

```bash
# Check Terraform state
terraform show

# View outputs
terraform output

# Refresh state
terraform refresh

# Import existing resources
terraform import aws_instance.example i-1234567890abcdef0
```

## Next Steps

- Configure HTTPS with SSL certificates
- Set up CI/CD pipeline
- Add backup and disaster recovery
- Implement blue-green deployments
- Add application-specific health checks
