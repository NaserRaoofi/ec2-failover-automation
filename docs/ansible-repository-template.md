# EC2 Failover Ansible Configuration

This repository contains Ansible playbooks and roles for automatically configuring EC2 instances in the EC2 Failover Infrastructure project.

## 🚀 Quick Start

1. **Fork this repository** or create a new one with this structure
2. **Customize the configurations** in `group_vars/all.yml` and individual roles
3. **Update your EC2 instance** to point to your repository:
   ```bash
   sudo nano /opt/ansible/sync-from-github.sh
   # Update: GITHUB_REPO="https://github.com/YOUR_USERNAME/YOUR_REPO.git"
   ```
4. **Sync and run**:
   ```bash
   sudo /opt/ansible/sync-from-github.sh
   sudo /opt/ansible/run-playbook.sh
   ```

## 📁 Repository Structure

```
├── README.md                    # This file
├── ansible.cfg                  # Global Ansible configuration
├── playbooks/
│   ├── site.yml                # Main orchestration playbook
│   ├── webserver.yml           # Web server specific tasks
│   ├── monitoring.yml          # Monitoring and logging
│   └── docker.yml              # Docker installation
├── roles/
│   ├── common/                 # Basic system configuration
│   ├── webserver/              # Apache/Nginx setup
│   ├── monitoring/             # CloudWatch agent & logging
│   ├── docker/                 # Docker engine installation
│   └── nodejs/                 # Node.js runtime
├── group_vars/
│   ├── all.yml                 # Global variables
│   └── webservers.yml          # Web server variables
├── host_vars/
│   └── localhost.yml           # Local host specific vars
└── inventory/
    └── hosts                   # Inventory file (merged with local)
```

## 🎯 Main Playbook

The `site.yml` playbook orchestrates the entire configuration:

```yaml
---
- name: Configure EC2 Instance for High Availability
  hosts: localhost
  become: yes
  gather_facts: yes
  
  vars:
    project_name: "{{ ansible_env.PROJECT_NAME | default('ec2-failover') }}"
    environment: "{{ ansible_env.ENVIRONMENT | default('dev') }}"
    
  pre_tasks:
    - name: Update package cache
      yum:
        update_cache: yes
      
  roles:
    - common          # Essential system packages and configuration
    - webserver       # Apache HTTP server with health checks
    - monitoring      # CloudWatch agent and log shipping
    - docker          # Docker engine for containerized apps
    - nodejs          # Node.js runtime for modern applications
    
  post_tasks:
    - name: Final system check
      service_facts:
      
    - name: Log configuration completion
      lineinfile:
        path: /var/log/application.log
        line: "{{ ansible_date_time.iso8601 }}: Ansible configuration completed successfully"
        create: yes
```

## 🔧 Configuration Variables

Edit `group_vars/all.yml` to customize your deployment:

```yaml
---
# Project configuration
project_name: "ec2-failover"
environment: "dev"

# Web server configuration
web_server: "httpd"
web_port: 80
web_root: "/var/www/html"
enable_ssl: false

# Monitoring configuration
enable_cloudwatch: true
enable_elk_logging: true
log_retention_days: 14

# Application configuration
enable_docker: true
docker_users:
  - ec2-user
nodejs_version: "18"

# Security configuration
enable_firewall: false
ssh_port: 22
allow_root_login: false
```

## 🎭 Available Roles

### Common Role
- System package updates
- Essential tools installation (htop, git, curl, etc.)
- User configuration
- SSH hardening
- Log file setup

### Webserver Role
- Apache HTTP Server installation
- PHP runtime (optional)
- Custom index page with instance information
- Health check endpoints
- Log rotation

### Monitoring Role
- CloudWatch Agent installation and configuration
- Log shipping to CloudWatch
- Custom metrics collection
- System monitoring scripts

### Docker Role
- Docker Engine installation
- Docker Compose installation
- User permissions for Docker
- Container runtime optimization

### Node.js Role
- Node.js installation (configurable version)
- NPM global packages
- Development tools

## 🔄 Automatic Updates

The system automatically:
1. **Syncs from GitHub** daily at 2 AM
2. **Runs updated playbooks** if changes are detected
3. **Logs all activities** to `/var/log/ansible-github.log`
4. **Maintains idempotency** for safe repeated execution

Manual update commands:
```bash
# Sync latest changes
sudo /opt/ansible/sync-from-github.sh

# Run configuration
sudo /opt/ansible/run-playbook.sh

# Check logs
sudo tail -f /var/log/ansible-setup.log
```

## 📊 Monitoring and Logs

### Log Files
- `/var/log/ansible-setup.log` - Playbook execution
- `/var/log/ansible-github.log` - GitHub sync activities  
- `/var/log/application.log` - Application events
- `/var/log/ansible.log` - Ansible runtime logs

### CloudWatch Integration
All logs are automatically shipped to CloudWatch:
- **System logs**: `/aws/ec2/{project_name}/system`
- **Application logs**: `/aws/ec2/{project_name}/application`
- **Web server logs**: `/aws/ec2/{project_name}/webserver`

## 🛠️ Customization Examples

### Adding a New Service

1. **Create a new role**:
   ```bash
   mkdir -p roles/myservice/{tasks,handlers,templates,files,vars,defaults}
   ```

2. **Define tasks** in `roles/myservice/tasks/main.yml`:
   ```yaml
   ---
   - name: Install my service
     yum:
       name: myservice
       state: present
       
   - name: Configure my service
     template:
       src: myservice.conf.j2
       dest: /etc/myservice/myservice.conf
     notify: restart myservice
   ```

3. **Add handlers** in `roles/myservice/handlers/main.yml`:
   ```yaml
   ---
   - name: restart myservice
     systemd:
       name: myservice
       state: restarted
   ```

4. **Include in site.yml**:
   ```yaml
   roles:
     - common
     - webserver
     - monitoring
     - myservice  # Add your new role
   ```

### Custom Web Content

Modify `roles/webserver/templates/index.html.j2` to customize the web page:

```html
<!DOCTYPE html>
<html>
<head>
    <title>{{ project_name }} - {{ environment }}</title>
</head>
<body>
    <h1>My Custom Application</h1>
    <p>Instance: {{ ansible_hostname }}</p>
    <p>Environment: {{ environment }}</p>
    <!-- Add your custom content -->
</body>
</html>
```

## 🧪 Testing

### Local Testing

Test playbooks locally before deployment:

```bash
# Syntax check
ansible-playbook --syntax-check playbooks/site.yml

# Dry run
ansible-playbook -i inventory/hosts playbooks/site.yml --check

# Run with verbose output
ansible-playbook -i inventory/hosts playbooks/site.yml -vvv
```

### Integration Testing

```bash
# Test web server
curl http://localhost/
curl http://localhost/health

# Test Docker
docker run hello-world

# Test Node.js
node --version
npm --version

# Check services
systemctl status httpd
systemctl status docker
systemctl status amazon-cloudwatch-agent
```

## 🔍 Troubleshooting

### Common Issues

1. **Permission Denied**:
   ```bash
   sudo chown -R root:root /opt/ansible
   sudo chmod -R 755 /opt/ansible
   ```

2. **GitHub Clone Fails**:
   - Verify repository URL
   - Ensure repository is public or configure SSH keys

3. **Playbook Execution Fails**:
   ```bash
   # Check syntax
   ansible-playbook --syntax-check playbooks/site.yml
   
   # Run in check mode
   ansible-playbook -i inventory/hosts playbooks/site.yml --check
   ```

4. **Service Not Starting**:
   ```bash
   # Check service status
   systemctl status service-name
   
   # View service logs
   journalctl -u service-name -f
   ```

### Debug Commands

```bash
# List all tasks
ansible-playbook -i inventory/hosts playbooks/site.yml --list-tasks

# List all tags
ansible-playbook -i inventory/hosts playbooks/site.yml --list-tags

# Run specific role
ansible-playbook -i inventory/hosts playbooks/site.yml --tags="webserver"

# Skip specific role
ansible-playbook -i inventory/hosts playbooks/site.yml --skip-tags="docker"
```

## 🤝 Contributing

1. Fork this repository
2. Create a feature branch
3. Test your changes thoroughly
4. Submit a pull request with description

## 📚 Additional Resources

- [Ansible Documentation](https://docs.ansible.com/)
- [AWS CloudWatch Agent](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Install-CloudWatch-Agent.html)
- [EC2 Failover Infrastructure](https://github.com/your-username/ec2-failover)

---

**Note**: This repository is designed to work with the EC2 Failover Infrastructure Terraform project. Make sure your EC2 instances are configured to pull from this repository during boot time.
