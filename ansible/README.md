# 🎭 EC2 Failover Infrastructure - Ansible Configuration

This directory contains all Ansible playbooks, roles, and configurations for automatically setting up and managing EC2 instances in the failover infrastructure.

## 📁 Directory Structure

```
ansible/
├── README.md                    # This file
├── ansible.cfg                  # Ansible configuration
├── playbooks/
│   └── site.yml                # Main orchestration playbook
├── roles/
│   ├── common/                 # Basic system configuration
│   │   ├── tasks/main.yml     # Core system setup tasks
│   │   ├── handlers/main.yml  # Service restart handlers
│   │   └── vars/main.yml      # Role-specific variables
│   ├── webserver/             # Apache web server setup
│   │   ├── tasks/main.yml     # Web server installation & config
│   │   ├── handlers/main.yml  # HTTP service handlers
│   │   └── templates/         # Jinja2 templates
│   │       ├── index.html.j2  # Main web page template
│   │       └── health-api.php.j2  # Health check API
│   ├── monitoring/            # System monitoring & logging
│   │   ├── tasks/main.yml     # CloudWatch agent setup
│   │   ├── handlers/main.yml  # Monitoring service handlers
│   │   └── templates/         # Configuration templates
│   │       ├── cloudwatch-config.json.j2
│   │       ├── collectd.conf.j2
│   │       └── system-monitor.sh.j2
│   ├── docker/                # Docker engine installation
│   │   └── tasks/main.yml     # Docker & Docker Compose setup
│   ├── nodejs/                # Node.js runtime installation
│   │   └── tasks/main.yml     # Node.js & NPM setup
│   └── security/              # Security hardening
│       ├── tasks/main.yml     # SSH, firewall, fail2ban
│       └── handlers/main.yml  # Security service handlers
├── group_vars/
│   └── all.yml                # Global variables for all hosts
├── host_vars/                 # Host-specific variables (if needed)
└── inventory/
    └── hosts                  # Inventory definitions
```

## 🚀 Quick Start

### 1. Use with EC2 User Data
This Ansible configuration is automatically used by EC2 instances through the user data script. The instances will:
1. Install Ansible
2. Clone this repository
3. Execute the `site.yml` playbook
4. Configure themselves automatically

### 2. Manual Execution
To run manually on an EC2 instance:

```bash
# Clone the repository (if not already done)
git clone https://github.com/YOUR_USERNAME/ec2-failover.git
cd ec2-failover/ansible

# Run the main playbook
ansible-playbook -i inventory/hosts playbooks/site.yml

# Run specific roles
ansible-playbook -i inventory/hosts playbooks/site.yml --tags="webserver"
ansible-playbook -i inventory/hosts playbooks/site.yml --tags="monitoring"
```

### 3. Check Mode (Dry Run)
```bash
ansible-playbook -i inventory/hosts playbooks/site.yml --check
```

## 🎯 What Gets Configured

### ✅ Common System Setup
- System package updates
- Essential tools installation (htop, git, curl, etc.)
- User management and SSH configuration
- Log file setup and rotation
- Timezone configuration

### ✅ Web Server (Apache)
- Apache HTTP Server installation
- PHP runtime with extensions
- Custom web page with system information
- Health check endpoints (`/health`, `/api.php`)
- Security hardening (hide version info)

### ✅ Monitoring & Logging
- CloudWatch Agent configuration
- Custom system monitoring scripts
- Log shipping to CloudWatch
- Collectd for additional metrics
- Automated log rotation

### ✅ Development Tools
- Docker Engine & Docker Compose
- Node.js runtime (configurable version)
- NPM global packages (PM2, nodemon)
- Development directories

### ✅ Security Hardening
- SSH security configuration
- Fail2ban for intrusion prevention
- Firewall configuration (optional)
- Kernel security parameters
- Automatic security updates

## 🔧 Configuration Variables

Key variables in `group_vars/all.yml`:

```yaml
# Project settings
project_name: "ec2-failover"
deployment_environment: "dev"

# Web server
web_server: "httpd"
web_port: 80

# Monitoring
enable_cloudwatch: true
enable_elk_logging: true
log_retention_days: 14

# Applications
enable_docker: true
nodejs_version: "18"

# Security
enable_firewall: false
ssh_port: 22
allow_root_login: false
```

## 📊 Monitoring & Health Checks

### Health Endpoints
- **Simple Check**: `http://instance-ip/health` → Returns "OK"
- **Detailed API**: `http://instance-ip/api.php` → Returns JSON with system info

### Logs
- **Application logs**: `/var/log/application.log`
- **Ansible logs**: `/var/log/ansible.log`
- **System monitoring**: `/var/log/system-monitor.log`
- **Web server**: `/var/log/httpd/access_log`, `/var/log/httpd/error_log`

### CloudWatch Integration
All logs are automatically shipped to CloudWatch:
- `/aws/ec2/{project_name}/system` - System logs
- `/aws/ec2/{project_name}/application` - Application logs
- `/aws/ec2/{project_name}/automation` - Ansible logs
- `/aws/ec2/{project_name}/monitoring` - Custom monitoring logs

## 🛠️ Customization

### Adding New Roles
1. Create role directory: `mkdir -p roles/newrole/{tasks,handlers,templates}`
2. Define tasks in `roles/newrole/tasks/main.yml`
3. Add role to `playbooks/site.yml`

### Modifying Variables
Edit `group_vars/all.yml` to change global settings or create host-specific vars in `host_vars/`

### Custom Templates
Place Jinja2 templates in `roles/{role}/templates/` and reference them in tasks

## 🏷️ Tags

Use tags to run specific parts of the configuration:

```bash
# Available tags
ansible-playbook playbooks/site.yml --list-tags

# Run specific tags
ansible-playbook playbooks/site.yml --tags="system,packages"
ansible-playbook playbooks/site.yml --tags="webserver"
ansible-playbook playbooks/site.yml --tags="monitoring"
ansible-playbook playbooks/site.yml --tags="security"

# Skip specific tags
ansible-playbook playbooks/site.yml --skip-tags="docker"
```

## 🧪 Testing & Validation

### Syntax Check
```bash
ansible-playbook playbooks/site.yml --syntax-check
```

### Dry Run
```bash
ansible-playbook playbooks/site.yml --check
```

### Connectivity Test
```bash
ansible all -m ping
```

### Service Validation
```bash
# Check web server
curl http://localhost/health
curl http://localhost/api.php

# Check services
systemctl status httpd
systemctl status docker
systemctl status amazon-cloudwatch-agent
```

## 🔄 Integration with Terraform

This Ansible configuration integrates seamlessly with the Terraform infrastructure:

1. **EC2 User Data**: Automatically runs on instance boot
2. **Auto Scaling**: New instances self-configure
3. **Load Balancer**: Health checks work with configured endpoints
4. **CloudWatch**: Logs and metrics integrate with monitoring stack
5. **ELK Stack**: Centralized logging via OpenSearch

## 📚 Best Practices

1. **Idempotency**: All tasks are designed to be run multiple times safely
2. **Error Handling**: Tasks include proper error handling and validation
3. **Logging**: Comprehensive logging for troubleshooting
4. **Security**: Security hardening applied by default
5. **Modularity**: Roles are independent and reusable
6. **Documentation**: All tasks and variables are documented

## 🤝 Contributing

1. Test changes in development environment
2. Use proper Ansible best practices
3. Document new variables and roles
4. Ensure idempotency of all tasks
5. Add appropriate tags to new tasks

---

**🎭 Role-Based Access**: This configuration supports the multi-role development approach with specific configurations for different team roles (SRE, DevOps, Security, etc.)
