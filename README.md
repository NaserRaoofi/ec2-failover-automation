# 🚀 EC2 Failover Infrastructure - Enterprise-Grade AWS Auto Scaling

**Version 2.0** | Last Updated: July 11, 2025 | **Production-Ready**

A **comprehensive, enterprise-grade** Terraform project implementing production-ready AWS infrastructure with **automatic failover**, **multi-layered health checks**, **centralized logging via ELK stack**, **secure bastion access**, and **modular architecture** designed for high availability and DevSecOps best practices.

> **🏆 Featured Architecture**: This project showcases **excellent visualization** and **production-grade design patterns** with comprehensive monitoring, security, and automation capabilities.

## 🎯 Project Features & Capabilities

### 🏗️ **Infrastructure Excellence**
- ✅ **9 Specialized Terraform Modules** - Modular architecture for maintainable infrastructure
- ✅ **Multi-AZ High Availability** - Automatic failover across availability zones with zero downtime
- ✅ **Auto Scaling Groups** - Dynamic scaling based on demand with health monitoring
- ✅ **Application Load Balancer** - Traffic distribution with advanced health checks
- ✅ **Launch Templates** - Versioned instance configurations with GP3 storage

### 🔐 **Security & Access**
- ✅ **Secure Bastion Host** - SSH access to private instances with Elastic IP
- ✅ **IAM Best Practices** - Centralized roles and policies with least privilege
- ✅ **VPC Security Groups** - Granular network access controls between tiers
- ✅ **EBS Encryption** - Encrypted storage volumes with IMDSv2 enforcement
- ✅ **Private Subnets** - Application instances isolated from direct internet access

### 📊 **Monitoring & Observability**
- ✅ **ELK Stack Integration** - Centralized logging with OpenSearch and Kibana dashboards
- ✅ **CloudWatch Monitoring** - Comprehensive metrics, alarms, and dashboards
- ✅ **SNS Notifications** - Email alerts for critical infrastructure events
- ✅ **Multi-Layer Health Checks** - ALB, Route 53, and instance-level monitoring
- ✅ **Cost Tracking** - Resource tagging for detailed cost allocation

### 🎭 **Automation & Configuration**
- ✅ **Ansible Integration** - Complete instance configuration from GitHub repository
- ✅ **GitHub Synchronization** - Daily automated sync of configuration updates
- ✅ **Self-Configuring Instances** - Automatic software installation and service setup
- ✅ **Role-Based Development** - Structured guidance for different engineering disciplines
- ✅ **Idempotent Operations** - Safe, repeatable configuration management

### 🌐 **Networking & DNS**
- ✅ **Route 53 Integration** - DNS management with health check routing
- ✅ **NAT Gateway** - Secure outbound internet access for private instances
- ✅ **Multi-AZ Deployment** - Resources distributed across availability zones
- ✅ **CIDR Management** - Organized subnet allocation and network planning

## 📋 Version History

| Version | Date | Key Features | Status |
|---------|------|--------------|--------|
| **2.0** | July 11, 2025 | ELK Stack, Bastion Host, Enhanced Security, Ansible Automation | ✅ **Current** |
| 1.5 | June 2025 | Modular Architecture, Auto Scaling, Load Balancer Integration | ✅ Stable |
| 1.0 | May 2025 | Basic EC2 Failover, CloudWatch Monitoring, Initial Terraform Setup | ✅ Legacy |

### 🆕 Version 2.0 Features
- **🔍 ELK Stack**: Centralized logging with OpenSearch, Kibana dashboards, and log shipping
- **🏰 Bastion Host**: Secure SSH access with Elastic IP and proper security group configuration
- **🎭 Ansible Integration**: Complete configuration management with GitHub synchronization
- **🔐 Enhanced Security**: IAM centralization, encryption, and DevSecOps best practices
- **📊 Advanced Monitoring**: Multi-layer health checks and comprehensive alerting
- **🏗️ Module Expansion**: 9 specialized modules for enterprise-grade infrastructure

---

## 🏗️ Architecture Overview

```mermaid
graph TB
    subgraph "Internet"
        Users[👥 Users]
        DNS[🌐 Route 53<br/>DNS + Health Checks]
    end
    
    subgraph "AWS VPC - Multi-AZ"
        subgraph "Public Subnets"
            ALB[⚖️ Application<br/>Load Balancer]
            NAT1[🔀 NAT Gateway<br/>AZ-1a]
            NAT2[🔀 NAT Gateway<br/>AZ-1b]
        end
        
        subgraph "Private Subnets"
            subgraph "AZ-1a"
                EC2_1[🖥️ EC2 Instance<br/>Auto Scaling Group]
            end
            subgraph "AZ-1b" 
                EC2_2[🖥️ EC2 Instance<br/>Auto Scaling Group]
            end
        end
        
        subgraph "Infrastructure Modules"
            LT[📋 Launch Template<br/>Module]
            ASG[📈 Auto Scaling<br/>Module]
            IAM[🔐 IAM Module<br/>Roles & Policies]
            MON[📊 Monitoring<br/>Module]
        end
    end
    
    Users --> DNS
    DNS --> ALB
    ALB --> EC2_1
    ALB --> EC2_2
    
    LT --> ASG
    ASG --> EC2_1
    ASG --> EC2_2
    IAM --> EC2_1
    IAM --> EC2_2
    MON --> ALB
    MON --> ASG
    
    EC2_1 --> NAT1
    EC2_2 --> NAT2
```

## 🔄 Automatic Failover Flow

```mermaid
sequenceDiagram
    participant User as 👥 Users
    participant R53 as 🌐 Route 53
    participant ALB as ⚖️ Load Balancer
    participant ASG as 📈 Auto Scaling Group
    participant EC2_OLD as 🖥️ Failed Instance
    participant LT as 📋 Launch Template
    participant EC2_NEW as ✨ New Instance
    participant CW as 📊 CloudWatch

    Note over EC2_OLD: 🚨 Service Failure Occurs
    
    ALB->>EC2_OLD: Health Check (HTTP GET /)
    EC2_OLD-->>ALB: ❌ No Response (Timeout)
    
    Note over ALB: After 2 failed checks (60s)
    ALB->>ALB: Mark Instance Unhealthy
    ALB->>User: Stop routing traffic
    
    ASG->>ALB: Monitor target health status
    Note over ASG: Grace Period: 300s (5 minutes)
    ASG->>ASG: Instance still unhealthy
    
    ASG->>LT: Request new instance config
    LT-->>ASG: Instance configuration
    ASG->>EC2_NEW: Launch replacement instance
    
    Note over EC2_NEW: User data script runs<br/>Web server starts
    
    ALB->>EC2_NEW: Health Check (HTTP GET /)
    EC2_NEW-->>ALB: ✅ 200 OK
    
    Note over ALB: After 2 healthy checks (60s)
    ALB->>ALB: Mark Instance Healthy
    ALB->>User: Resume traffic routing
    
    ASG->>EC2_OLD: Terminate failed instance
    CW->>CW: Log metrics and alerts
    
    Note over User: 🎉 Service Restored<br/>Zero downtime achieved
```

## 🎨 Architecture Visualization - Excellence in Design

> **🏆 Visual Excellence**: This project features **outstanding architectural visualization** with comprehensive Mermaid diagrams that clearly illustrate complex infrastructure relationships, data flows, and operational procedures.

### 🌟 Complete Infrastructure Diagram

```mermaid
graph TB
    subgraph "External Access"
        Users[👥 Users]
        DNS[🌐 Route 53<br/>Health Checks & DNS]
        Bastion[🔒 Bastion Host<br/>10.0.1.138<br/>EIP: 13.223.40.186]
    end
    
    subgraph "AWS VPC - 10.0.0.0/16"
        subgraph "Public Subnets - DMZ"
            subgraph "us-east-1a - 10.0.1.0/24"
                ALB[⚖️ Application<br/>Load Balancer<br/>Port 80/443]
                NAT1[🔀 NAT Gateway<br/>AZ-1a]
                Bastion
            end
            subgraph "us-east-1b - 10.0.2.0/24"
                NAT2[🔀 NAT Gateway<br/>AZ-1b]
            end
        end
        
        subgraph "Private Subnets - Application Tier"
            subgraph "us-east-1a - 10.0.10.0/24"
                EC2_1[🖥️ EC2 Instance<br/>10.0.20.205<br/>Auto Scaling Group]
            end
            subgraph "us-east-1b - 10.0.20.0/24" 
                EC2_2[🖥️ EC2 Instance<br/>10.0.20.241<br/>Auto Scaling Group]
            end
        end
        
        subgraph "Data & Analytics"
            ELK[📊 OpenSearch/ELK<br/>Centralized Logging<br/>& Analytics]
            CloudWatch[📈 CloudWatch<br/>Metrics & Alarms]
            SNS[📧 SNS Topics<br/>Alert Notifications]
        end
    end
    
    subgraph "Infrastructure Modules"
        LT[📋 Launch Template<br/>GP3, IMDSv2, Encryption]
        ASG[📈 Auto Scaling Group<br/>Min:1, Max:5, Desired:2]
        IAM[🔐 IAM Module<br/>Roles & Policies]
        MON[📊 Monitoring Module<br/>Dashboards & Alerts]
        BastionMod[🏰 Bastion Module<br/>Secure SSH Access]
        ELKMod[🔍 ELK Module<br/>Log Aggregation]
    end
    
    subgraph "Automation & Config"
        Ansible[🎭 Ansible<br/>Configuration Management]
        GitHub[📚 GitHub<br/>Ansible Playbooks]
    end
    
    Users --> DNS
    Users -.-> Bastion
    DNS --> ALB
    ALB --> EC2_1
    ALB --> EC2_2
    
    Bastion -.-> EC2_1
    Bastion -.-> EC2_2
    
    LT --> ASG
    ASG --> EC2_1
    ASG --> EC2_2
    IAM --> EC2_1
    IAM --> EC2_2
    BastionMod --> Bastion
    ELKMod --> ELK
    
    EC2_1 --> NAT1
    EC2_2 --> NAT2
    EC2_1 --> ELK
    EC2_2 --> ELK
    EC2_1 --> CloudWatch
    EC2_2 --> CloudWatch
    CloudWatch --> SNS
    
    EC2_1 -.-> GitHub
    EC2_2 -.-> GitHub
    GitHub -.-> Ansible
    Ansible -.-> EC2_1
    Ansible -.-> EC2_2
    
    style Bastion fill:#e1f5fe
    style ELK fill:#f3e5f5
    style ALB fill:#e8f5e8
    style EC2_1 fill:#fff3e0
    style EC2_2 fill:#fff3e0
```

### 🔄 Enhanced Failover & Recovery Visualization

```mermaid
sequenceDiagram
    participant User as 👥 Users
    participant R53 as 🌐 Route 53
    participant ALB as ⚖️ Load Balancer
    participant ASG as 📈 Auto Scaling Group
    participant EC2_OLD as 🖥️ Failed Instance<br/>10.0.20.25
    participant LT as 📋 Launch Template
    participant EC2_NEW as ✨ New Instance<br/>10.0.20.205
    participant CW as 📊 CloudWatch
    participant ELK as 📊 ELK Stack
    participant Bastion as 🔒 Bastion Host

    Note over EC2_OLD: 🚨 Service Failure Detected
    
    ALB->>EC2_OLD: Health Check (HTTP GET /)
    EC2_OLD-->>ALB: ❌ Connection Timeout
    
    Note over ALB: 30s: First failed check
    ALB->>EC2_OLD: Health Check Retry
    EC2_OLD-->>ALB: ❌ Still failing
    
    Note over ALB: 60s: Second failed check
    ALB->>ALB: 🔴 Mark Instance Unhealthy
    ALB->>User: 🔀 Stop routing traffic to failed instance
    
    ALB->>ASG: 📊 Report instance unhealthy
    Note over ASG: 300s: Health check grace period
    ASG->>ASG: 🔍 Confirm instance still unhealthy
    
    ASG->>LT: 📋 Request new instance configuration
    LT-->>ASG: ✅ Instance config (AMI, security groups, etc.)
    ASG->>EC2_NEW: 🚀 Launch replacement instance
    
    Note over EC2_NEW: 🔧 User data script executes<br/>📦 Ansible pulls from GitHub<br/>🎭 Configure services automatically
    
    EC2_NEW->>GitHub: 📥 Pull Ansible configuration
    EC2_NEW->>EC2_NEW: 🎯 Run playbooks (web server, monitoring, etc.)
    EC2_NEW->>ELK: 📊 Start shipping logs
    EC2_NEW->>CW: 📈 Begin sending metrics
    
    ALB->>EC2_NEW: 🔍 Initial health check
    EC2_NEW-->>ALB: ⏳ Still starting up...
    
    Note over EC2_NEW: 120s: Services fully started
    ALB->>EC2_NEW: 🔍 Health Check (HTTP GET /)
    EC2_NEW-->>ALB: ✅ 200 OK - Ready to serve
    
    Note over ALB: 60s: Second successful check
    ALB->>ALB: 🟢 Mark Instance Healthy
    ALB->>User: 🔀 Resume full traffic routing
    
    ASG->>EC2_OLD: 💀 Terminate failed instance
    CW->>SNS: 📧 Send recovery notification
    ELK->>ELK: 📝 Log complete recovery timeline
    
    Note over User: 🎉 Service Fully Restored<br/>💡 Zero downtime achieved<br/>📊 All metrics normalized
    
    Note over Bastion: 🔒 SSH access available for<br/>troubleshooting throughout process
```

### 🔄 **Complete Data Flow & Integration**

```mermaid
graph TB
    subgraph "External Layer"
        Dev[👨‍💻 Developer]
        User[👥 End Users]
        GitHub[📚 GitHub Repository<br/>Ansible Playbooks]
    end
    
    subgraph "AWS VPC - Production Environment"
        subgraph "Public DMZ - 10.0.1.0/24, 10.0.2.0/24"
            Bastion[🔒 Bastion Host<br/>EIP: 13.223.40.186<br/>SSH Gateway]
            ALB[⚖️ Application Load Balancer<br/>Health Checks<br/>Traffic Distribution]
            NAT[🔀 NAT Gateways<br/>Outbound Internet Access]
        end
        
        subgraph "Private App Tier - 10.0.10.0/24, 10.0.20.0/24"
            ASG[📈 Auto Scaling Group<br/>Min: 1, Max: 5, Desired: 2]
            EC2_1[🖥️ Instance 1<br/>10.0.20.205<br/>Web Server + Ansible]
            EC2_2[🖥️ Instance 2<br/>10.0.20.241<br/>Web Server + Ansible]
        end
        
        subgraph "Data & Analytics Layer"
            ELK[🔍 OpenSearch Cluster<br/>vpc-ec2-failover-dev-elk<br/>Centralized Logging]
            CW[📊 CloudWatch<br/>Metrics & Dashboards<br/>Log Groups]
            SNS[📧 SNS Topics<br/>Alert Distribution]
        end
        
        subgraph "DNS & Routing"
            R53[🌐 Route 53<br/>Health Check Routing<br/>DNS Management]
        end
    end
    
    %% User Traffic Flow
    User -->|HTTP/HTTPS| R53
    R53 -->|DNS Resolution| ALB
    ALB -->|Load Balance| EC2_1
    ALB -->|Load Balance| EC2_2
    
    %% Developer Access Flow
    Dev -.->|SSH Key Auth| Bastion
    Bastion -.->|SSH Forward| EC2_1
    Bastion -.->|SSH Forward| EC2_2
    
    %% Configuration Management Flow
    GitHub -->|Pull Configs| EC2_1
    GitHub -->|Pull Configs| EC2_2
    EC2_1 -->|Apply Ansible| EC2_1
    EC2_2 -->|Apply Ansible| EC2_2
    
    %% Monitoring & Logging Flow
    EC2_1 -->|Logs & Metrics| CW
    EC2_2 -->|Logs & Metrics| CW
    EC2_1 -->|Application Logs| ELK
    EC2_2 -->|Application Logs| ELK
    ALB -->|Access Logs| ELK
    CW -->|Alerts| SNS
    ELK -->|Storage Alerts| SNS
    
    %% Auto Scaling Flow
    ALB -->|Health Status| ASG
    ASG -->|Launch/Terminate| EC2_1
    ASG -->|Launch/Terminate| EC2_2
    CW -->|Metrics| ASG
    
    %% Internet Access Flow
    EC2_1 -->|Outbound HTTPS| NAT
    EC2_2 -->|Outbound HTTPS| NAT
    
    style Bastion fill:#ffecb3,stroke:#ff6f00,stroke-width:3px
    style ELK fill:#e8f5e8,stroke:#2e7d32,stroke-width:3px
    style ALB fill:#dcedc8,stroke:#388e3c,stroke-width:3px
    style ASG fill:#bbdefb,stroke:#1976d2,stroke-width:3px
    style CW fill:#fff3e0,stroke:#ef6c00,stroke-width:3px
```

### 🎯 **Feature Integration Map**

```mermaid
graph LR
    subgraph "Security Features"
        BastionF[🔒 Bastion Host<br/>Secure SSH Access<br/>Key-based Authentication]
        IAMF[🛡️ IAM Security<br/>Centralized Policies<br/>Least Privilege]
        EncryptF[🔐 Encryption<br/>EBS Volumes<br/>Data at Rest]
    end
    
    subgraph "Automation Features"
        AnsibleF[🎭 Ansible Automation<br/>Configuration Management<br/>GitHub Integration]
        ASGF[📈 Auto Scaling<br/>Health-based Scaling<br/>Instance Replacement]
        LaunchF[📋 Launch Templates<br/>Versioned Configs<br/>GP3 Storage]
    end
    
    subgraph "Monitoring Features"
        ELKF[📊 ELK Stack<br/>Centralized Logging<br/>Real-time Analytics]
        CWF[📈 CloudWatch<br/>Metrics & Alarms<br/>Custom Dashboards]
        SNSF[📧 SNS Alerts<br/>Email Notifications<br/>Event-driven]
    end
    
    subgraph "High Availability Features"
        ALBF[⚖️ Load Balancer<br/>Health Checks<br/>Traffic Distribution]
        MultiAZF[🌍 Multi-AZ<br/>Cross-AZ Deployment<br/>Fault Tolerance]
        R53F[🌐 Route 53<br/>DNS Failover<br/>Health Routing]
    end
    
    BastionF --> AnsibleF
    IAMF --> ASGF
    AnsibleF --> ELKF
    ASGF --> ALBF
    ELKF --> CWF
    CWF --> SNSF
    ALBF --> MultiAZF
    MultiAZF --> R53F
    
    style BastionF fill:#ffcdd2
    style AnsibleF fill:#c8e6c9
    style ELKF fill:#bbdefb
    style ALBF fill:#dcedc8
```

---

## 🏗️ Complete Project Structure

```
📁 ec2-failover/                          # 🚀 Enterprise Infrastructure Project
├── 🏛️ modules/                          # 🎯 9 Specialized Infrastructure Modules
│   ├── 🌐 networking/                   # Core VPC Infrastructure
│   │   ├── main.tf                     # VPC, Subnets, NAT, IGW, Security Groups
│   │   ├── variables.tf                # CIDR blocks, AZ configuration
│   │   └── outputs.tf                  # VPC ID, subnet IDs, security group IDs
│   │
│   ├── ⚖️ load_balancer/               # Application Load Balancer
│   │   ├── main.tf                     # ALB, target groups, listeners
│   │   ├── variables.tf                # Health check settings, ports
│   │   └── outputs.tf                  # ALB DNS, target group ARNs
│   │
│   ├── 🌐 route53/                     # DNS Management & Health Checks
│   │   ├── main.tf                     # Hosted zones, health checks
│   │   ├── variables.tf                # Domain configuration
│   │   └── outputs.tf                  # Zone ID, DNS records
│   │
│   ├── 📋 launch_template/             # Instance Configuration Templates
│   │   ├── main.tf                     # Launch template, GP3, IMDSv2, encryption
│   │   ├── variables.tf                # Instance specs, storage, security
│   │   └── outputs.tf                  # Template ID, ARN, versions
│   │
│   ├── 📈 autoscaling/                 # Auto Scaling & Health Management
│   │   ├── main.tf                     # ASG, scaling policies, CloudWatch alarms
│   │   ├── variables.tf                # Min/max size, health check config
│   │   └── outputs.tf                  # ASG details, policy ARNs
│   │
│   ├── 🖥️ ec2/                         # EC2 Instance Management
│   │   ├── main.tf                     # Instance configuration, user data
│   │   ├── variables.tf                # AMI, instance type, key pairs
│   │   └── outputs.tf                  # Instance IDs, private IPs
│   │
│   ├── 🔐 iam/                         # Centralized IAM Security
│   │   ├── main.tf                     # EC2 roles, CloudWatch/SSM policies
│   │   ├── variables.tf                # SNS publishing, environment config
│   │   └── outputs.tf                  # Role ARNs, instance profiles
│   │
│   ├── 🏰 bastion/                     # Secure SSH Access Gateway
│   │   ├── main.tf                     # Bastion instance, EIP, security groups
│   │   ├── variables.tf                # SSH access configuration, key pairs
│   │   ├── outputs.tf                  # Bastion IP, SSH commands
│   │   └── user_data.sh               # Bastion initialization script
│   │
│   ├── 📊 monitoring/                  # CloudWatch & SNS Monitoring
│   │   ├── main.tf                     # CloudWatch alarms, SNS topics
│   │   ├── variables.tf                # Alert thresholds, email config
│   │   └── outputs.tf                  # Alarm ARNs, topic ARNs
│   │
│   └── 🔍 elk/                         # ELK Stack Centralized Logging
│       ├── main.tf                     # OpenSearch cluster, log groups
│       ├── variables.tf                # ELK configuration, retention
│       └── outputs.tf                  # OpenSearch endpoints, Kibana URLs
│
├── 🏢 environments/                     # Multi-Environment Orchestration
│   ├── 🧪 dev/                         # Development Environment
│   │   ├── main.tf                     # Module integration & configuration
│   │   ├── variables.tf                # Environment-specific variables
│   │   ├── outputs.tf                  # Environment outputs
│   │   ├── terraform.tfvars           # Actual variable values
│   │   ├── terraform.tfvars.example   # Template for configuration
│   │   └── terraform.tfstate          # State management
│   │
│   ├── 🎭 staging/                     # Staging Environment (Template)
│   └── 🏭 prod/                        # Production Environment (Template)
│
├── 🎭 ansible/                         # Configuration Management
│   ├── 📝 playbooks/                   # Ansible Playbooks
│   │   └── site.yml                   # Main configuration playbook
│   ├── 🎯 roles/                       # Modular Ansible Roles
│   │   ├── common/                     # Base system configuration
│   │   ├── webserver/                  # Apache/Nginx setup
│   │   ├── monitoring/                 # CloudWatch agent
│   │   ├── docker/                     # Container runtime
│   │   ├── nodejs/                     # Node.js applications
│   │   └── security/                   # Security hardening
│   ├── 📋 group_vars/                  # Global variables
│   ├── 🗂️ inventory/                   # Host inventories
│   ├── 📄 templates/                   # Configuration templates
│   ├── ⚙️ ansible.cfg                 # Ansible configuration
│   ├── 🔄 run-playbook.sh             # Playbook execution script
│   └── 📥 sync-from-github.sh         # GitHub synchronization
│
├── 🔧 scripts/                         # Automation & Deployment Scripts
│   ├── 🚀 deploy.sh                   # Complete infrastructure deployment
│   ├── 🧹 cleanup.sh                  # Resource cleanup and teardown
│   └── 🔍 health-check.sh            # Infrastructure health validation
│
├── 📚 docs/                            # Comprehensive Documentation
│   ├── 🏗️ architecture.md             # Detailed architecture decisions
│   ├── 💰 cost.md                     # Cost analysis & optimization
│   ├── 🚀 getting-started.md          # Setup and deployment guide
│   ├── 🔒 security.md                 # Security best practices
│   ├── 📊 monitoring.md               # Monitoring and alerting guide
│   └── 📝 change_log.md               # Version history and changes
│
├── 🎭 copilot_roles/                   # Role-Based Development Guidance
│   ├── 🏗️ aws_architect.md            # Infrastructure design guidance
│   ├── 🔧 sre.md                      # Site reliability engineering
│   ├── 🔐 devsecops.md                # Security & compliance practices
│   ├── 👨‍💻 devops_engineer.md           # Deployment & automation
│   ├── 🐧 linux_admin.md              # System administration
│   ├── 🐍 python_dev.md               # Python development practices
│   └── 📊 logging.md                  # Logging and monitoring
│
├── 📄 README.md                       # 📖 This comprehensive guide
├── 🔧 Makefile                        # Build automation commands
├── 📦 versions.tf                     # Terraform version constraints
└── ⚙️ .gitignore                      # Git ignore patterns

🎯 Total: 9 Infrastructure Modules | 60+ Configuration Files | Production-Ready
```


