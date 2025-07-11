# Ansible Integration Guide

This document explains how to set up and use Ansible automation with your EC2 failover infrastructure.

## Overview

The EC2 instances are automatically configured with Ansible during boot time via user data. Ansible is installed and configured to pull playbooks, roles, and configurations from a GitHub repository, enabling full infrastructure-as-code automation.

## Architecture

```
EC2 Instance Boot Process:
1. Install Python3, pip, git, and essential tools
2. Install Ansible via pip
3. Create basic Ansible configuration
4. Clone your GitHub repository with playbooks
5. Execute main playbook (site.yml)
6. Set up cron job for periodic updates
```

## Required GitHub Repository Structure

Create a GitHub repository with the following structure:

```
your-ansible-repo/
├── README.md
├── ansible.cfg                 # Optional: Override default config
├── inventory/
│   └── hosts                   # Optional: Merge with local inventory
├── playbooks/
│   ├── site.yml               # Main playbook (required)
│   ├── webserver.yml          # Web server configuration
│   ├── monitoring.yml         # Monitoring setup
│   └── docker.yml            # Docker installation
├── roles/
│   ├── common/
│   │   ├── tasks/main.yml
│   │   ├── handlers/main.yml
│   │   ├── vars/main.yml
│   │   ├── defaults/main.yml
│   │   ├── templates/
│   │   └── files/
│   ├── webserver/
│   │   ├── tasks/main.yml
│   │   ├── handlers/main.yml
│   │   ├── templates/
│   │   │   └── index.html.j2
│   │   └── files/
│   ├── monitoring/
│   │   ├── tasks/main.yml
│   │   ├── templates/
│   │   │   └── cloudwatch-config.json.j2
│   │   └── handlers/main.yml
│   └── docker/
│       ├── tasks/main.yml
│       └── defaults/main.yml
├── group_vars/
│   ├── all.yml               # Global variables
│   └── webservers.yml        # Web server specific variables
└── host_vars/
    └── localhost.yml         # Local host variables
```

## Sample Configuration Files

### 1. Main Playbook (`playbooks/site.yml`)

```yaml
---
- name: Configure EC2 Instance
  hosts: localhost
  become: yes
  gather_facts: yes
  
  vars:
    project_name: "{{ ansible_env.PROJECT_NAME | default('ec2-failover') }}"
    environment: "{{ ansible_env.ENVIRONMENT | default('dev') }}"
    
  roles:
    - common
    - webserver
    - monitoring
    - docker
```

### 2. Common Role (`roles/common/tasks/main.yml`)

```yaml
---
- name: Update system packages
  yum:
    name: "*"
    state: latest
    update_cache: yes

- name: Install essential packages
  yum:
    name:
      - htop
      - iotop
      - tcpdump
      - strace
      - lsof
      - sysstat
      - bind-utils
      - net-tools
      - amazon-ssm-agent
    state: present

- name: Start and enable SSM agent
  systemd:
    name: amazon-ssm-agent
    state: started
    enabled: yes

- name: Create application log file
  file:
    path: /var/log/application.log
    state: touch
    owner: root
    group: root
    mode: '0644'

- name: Log system setup completion
  lineinfile:
    path: /var/log/application.log
    line: "{{ ansible_date_time.iso8601 }}: Common system setup completed via Ansible"
    create: yes
```

### 3. Web Server Role (`roles/webserver/tasks/main.yml`)

```yaml
---
- name: Install Apache HTTP Server
  yum:
    name: httpd
    state: present

- name: Install PHP for API endpoints
  yum:
    name: php
    state: present

- name: Create web content from template
  template:
    src: index.html.j2
    dest: /var/www/html/index.html
    owner: apache
    group: apache
    mode: '0644'
  notify: restart httpd

- name: Create health check endpoint
  copy:
    content: "OK"
    dest: /var/www/html/health
    owner: apache
    group: apache
    mode: '0644'

- name: Start and enable Apache
  systemd:
    name: httpd
    state: started
    enabled: yes

- name: Log web server setup completion
  lineinfile:
    path: /var/log/application.log
    line: "{{ ansible_date_time.iso8601 }}: Web server configured via Ansible"
```

### 4. Global Variables (`group_vars/all.yml`)

```yaml
---
# Project configuration
project_name: "ec2-failover"
environment: "dev"

# Web server configuration
web_server: "httpd"
web_port: 80
health_check_path: "/health"

# Monitoring configuration
enable_cloudwatch: true
enable_elk_logging: true
log_retention_days: 14

# Docker configuration
enable_docker: true
docker_users:
  - ec2-user

# Node.js configuration
nodejs_version: "18"

# Security configuration
enable_firewall: false
ssh_port: 22
```

## Setup Instructions

### Step 1: Create Your GitHub Repository

1. Create a new repository on GitHub
2. Clone it locally and add the structure above
3. Commit and push your initial configuration

### Step 2: Configure Your EC2 Instance

1. Deploy your infrastructure using Terraform:
   ```bash
   cd environments/dev
   terraform plan
   terraform apply
   ```

2. Once the instance is running, SSH into it and update the GitHub repository URL:
   ```bash
   sudo nano /opt/ansible/sync-from-github.sh
   # Update the GITHUB_REPO variable with your repository URL
   ```

3. Sync your Ansible configuration from GitHub:
   ```bash
   sudo /opt/ansible/sync-from-github.sh
   ```

4. Run your playbook:
   ```bash
   sudo /opt/ansible/run-playbook.sh
   ```

### Step 3: Verify Configuration

1. Check the web application:
   ```bash
   curl http://localhost/
   curl http://localhost/health
   ```

2. Review logs:
   ```bash
   sudo tail -f /var/log/ansible-setup.log
   sudo tail -f /var/log/ansible-github.log
   sudo tail -f /var/log/application.log
   ```

## Automatic Updates

The system is configured with a cron job that runs daily at 2 AM to:
1. Pull the latest changes from your GitHub repository
2. Run the updated playbooks
3. Log all activities

You can manually trigger updates anytime:
```bash
sudo /opt/ansible/sync-from-github.sh && sudo /opt/ansible/run-playbook.sh
```

## Available Scripts

- `/opt/ansible/sync-from-github.sh` - Download latest Ansible files from GitHub
- `/opt/ansible/run-playbook.sh` - Execute the main playbook
- `/opt/ansible/ansible.cfg` - Ansible configuration
- `/opt/ansible/inventory/hosts` - Local inventory

## Logs and Monitoring

- `/var/log/ansible-setup.log` - Playbook execution logs
- `/var/log/ansible-github.log` - GitHub sync logs
- `/var/log/application.log` - Application and system logs
- `/var/log/ansible.log` - Ansible runtime logs

## Best Practices

1. **Version Control**: Keep all playbooks and roles in version control
2. **Idempotency**: Ensure all tasks are idempotent and can be run multiple times
3. **Testing**: Test playbooks in development before deploying to production
4. **Secrets**: Use Ansible Vault for sensitive data
5. **Documentation**: Document all roles and playbooks thoroughly

## Troubleshooting

### Common Issues

1. **GitHub Repository Not Found**:
   - Verify the repository URL in `/opt/ansible/sync-from-github.sh`
   - Ensure the repository is public or configure SSH keys

2. **Playbook Execution Fails**:
   - Check syntax: `ansible-playbook --syntax-check playbooks/site.yml`
   - Review logs: `sudo tail -f /var/log/ansible-setup.log`

3. **Permission Issues**:
   - Ensure proper ownership: `sudo chown -R root:root /opt/ansible`
   - Check file permissions: `sudo chmod -R 755 /opt/ansible`

### Debug Commands

```bash
# Test Ansible connectivity
ansible localhost -m ping

# Run playbook in check mode
ansible-playbook -i inventory/hosts playbooks/site.yml --check

# Run playbook with verbose output
ansible-playbook -i inventory/hosts playbooks/site.yml -vvv

# List available tasks
ansible-playbook -i inventory/hosts playbooks/site.yml --list-tasks
```

## Integration with Infrastructure

The Ansible automation integrates seamlessly with the AWS infrastructure:

- **Auto Scaling**: New instances automatically configure themselves
- **Load Balancer**: Health checks work with Ansible-configured endpoints
- **Monitoring**: CloudWatch logs capture Ansible execution details
- **ELK Stack**: Centralized logging includes Ansible activity logs

This creates a fully automated, self-configuring infrastructure that maintains consistency across all instances.
