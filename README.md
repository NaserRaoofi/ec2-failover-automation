# 🚀 EC2 Failover Automation

A production-ready, modular Terraform project for AWS infrastructure with automated failover capabilities, comprehensive cost tracking, and role-based development workflow.

## 🏗️ Architecture Overview

This project implements a highly available, cost-optimized AWS infrastructure with:

- **Multi-AZ VPC** with public/private subnets
- **Application Load Balancer** with health checks
- **EC2 instances** in private subnets with NAT Gateway access
- **Optional Route 53** DNS management
- **Comprehensive monitoring** and alerting
- **Role-based Copilot system** for infrastructure governance

## 📊 Cost Optimization

**Monthly Cost Estimates:**
- **Development**: ~$96.63/month (~$89 with AWS Free Tier)
- **Production**: ~$124.75/month
- **Testing**: ~$0.32 for 4-hour testing sessions

See [docs/cost.md](docs/cost.md) for detailed cost breakdown and optimization strategies.

## 🏛️ Project Structure

```
.
├── modules/                    # Reusable Terraform modules
│   ├── ec2/                   # EC2 instance with user data
│   ├── networking/            # VPC, subnets, security groups, NAT
│   ├── load_balancer/         # Application Load Balancer + targets
│   ├── route53/               # DNS management (conditional)
│   └── monitoring/            # CloudWatch, SNS (optional)
├── environments/              # Environment-specific configurations
│   ├── dev/                   # Development environment
│   ├── staging/               # Staging environment
│   └── prod/                  # Production environment
├── scripts/                   # Helper scripts
│   ├── deploy.sh              # Deployment automation
│   └── cleanup.sh             # Resource cleanup
├── docs/                      # Documentation
│   ├── architecture.md        # Architecture decisions
│   ├── cost.md               # Cost analysis & optimization
│   ├── getting-started.md     # Setup instructions
│   └── change_log.md          # Change tracking
├── copilot_roles/             # Role-based development system
│   ├── main.md               # Primary role definitions
│   ├── aws_architect.md      # AWS architecture guidance
│   ├── devops_engineer.md    # DevOps workflows
│   └── [other roles]         # Specialized roles
└── Makefile                   # Common operations
```

## 🔧 Prerequisites

- **AWS CLI** configured with appropriate credentials
- **Terraform** >= 1.0
- **Git** for version control
- **IAM permissions** for EC2, VPC, ELB, Route 53, CloudWatch

## 🚀 Quick Start

### 1. Clone and Setup
```bash
git clone https://github.com/NaserRaoofi/ec2-failover-automation.git
cd ec2-failover
```

### 2. Configure Environment
```bash
cd environments/dev
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your settings
```

### 3. Deploy Infrastructure
```bash
terraform init
terraform plan
terraform apply
```

### 4. Access Your Application
```bash
# Your application will be available at:
terraform output application_url
```

## 🎯 Key Features

### 🔒 **Security**
- EC2 instances in private subnets
- Encrypted EBS volumes
- Security groups with minimal required access
- NAT Gateways for secure outbound access

### 🌐 **High Availability**
- Multi-AZ deployment across 2 availability zones
- Application Load Balancer with health checks
- Auto-recovery mechanisms
- Redundant NAT Gateways

### 💰 **Cost Optimization**
- t3.micro instances (Free Tier eligible)
- Conditional Route 53 (disabled by default)
- Comprehensive cost tracking
- Multiple cost-saving deployment options

### 📈 **Monitoring & Alerting**
- CloudWatch metrics and alarms
- SNS notifications to specified email addresses
- Load balancer and instance health monitoring
- Cost monitoring and billing alerts

### 🔄 **Infrastructure as Code**
- Modular Terraform design
- Environment-specific configurations
- Version-controlled infrastructure
- Automated deployment scripts

## 📋 Available Environments

| Environment | Purpose | Cost | Features |
|-------------|---------|------|----------|
| **dev** | Development & Testing | ~$96.63/month | Basic setup, cost-optimized |
| **staging** | Pre-production | ~$110/month | Production-like, monitoring |
| **prod** | Production | ~$124.75/month | Full features, HA, monitoring |

## 🛠️ Common Operations

### Deploy to Development
```bash
make dev-deploy
```

### Check Costs
```bash
make cost-estimate
```

### Cleanup Resources
```bash
make cleanup
```

### Validate Configuration
```bash
make validate
```

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [Getting Started](docs/getting-started.md) | Detailed setup instructions |
| [Architecture](docs/architecture.md) | Architecture decisions and patterns |
| [Cost Analysis](docs/cost.md) | Comprehensive cost breakdown |
| [Change Log](docs/change_log.md) | Infrastructure change tracking |

## 🎭 Role-Based Development

This project uses a **Copilot Role System** for structured development:

- **AWS Architect**: Infrastructure design and cost optimization
- **DevOps Engineer**: CI/CD and deployment automation
- **Security Engineer**: Security best practices and compliance
- **Site Reliability Engineer**: Monitoring and operational excellence

See [copilot_roles/main.md](copilot_roles/main.md) for detailed role definitions.

## 📊 Current Infrastructure Status

**Deployed Resources:**
- ✅ VPC with public/private subnets
- ✅ Application Load Balancer
- ✅ EC2 t3.micro instance
- ✅ NAT Gateways (2x for HA)
- ✅ Security Groups
- ✅ Route Tables and Internet Gateway
- ❌ Route 53 (disabled for cost optimization)
- ❌ CloudWatch monitoring (optional)

**Application URL:** `http://ec2-failover-dev-alb-529865572.us-east-1.elb.amazonaws.com`

## 🔍 Troubleshooting

### Common Issues

1. **502 Bad Gateway**: Check target group health and security groups
2. **High Costs**: Review [cost.md](docs/cost.md) for optimization strategies
3. **Access Issues**: Verify AWS CLI region configuration
4. **Deployment Failures**: Check IAM permissions and Terraform state

### Getting Help

1. Check the [docs/](docs/) directory for detailed documentation
2. Review the [change log](docs/change_log.md) for recent changes
3. Examine the [copilot roles](copilot_roles/) for development guidance

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Follow the role-based development approach
2. Update cost documentation for any changes
3. Maintain comprehensive change logs
4. Test in development environment first

## 📞 Support

For questions or issues:
- Create an issue in the GitHub repository
- Review the documentation in `docs/`
- Check the role-based guidance in `copilot_roles/`
