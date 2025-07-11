# General Configuration
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "ec2-failover-dev"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# Networking Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

# EC2 Configuration
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
  default     = null
}

# Storage Configuration
variable "root_volume_size" {
  description = "Size of the root EBS volume in GB"
  type        = number
  default     = 8
}

variable "root_volume_type" {
  description = "Type of root EBS volume"
  type        = string
  default     = "gp3"
}

variable "enable_ebs_encryption" {
  description = "Enable EBS volume encryption"
  type        = bool
  default     = true
}

# Monitoring Configuration
variable "enable_detailed_monitoring" {
  description = "Enable detailed monitoring for EC2 instances"
  type        = bool
  default     = false
}

variable "enable_sns_publishing" {
  description = "Enable SNS publishing permissions for EC2 instances"
  type        = bool
  default     = false
}

# Auto Scaling Group Configuration
variable "min_size" {
  description = "Minimum number of instances in the Auto Scaling Group"
  type        = number
  default     = 1  # At least 1 instance for availability
}

variable "max_size" {
  description = "Maximum number of instances in the Auto Scaling Group"
  type        = number
  default     = 3  # Allow scaling for high demand
}

variable "desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group"
  type        = number
  default     = 2  # Start with 2 instances across AZs for redundancy
}

# Health Check Configuration
variable "health_check_type" {
  description = "Type of health check (ELB or EC2)"
  type        = string
  default     = "ELB"  # Use ELB health checks for better detection
}

variable "health_check_grace_period" {
  description = "Time in seconds after instance launch before checking health"
  type        = number
  default     = 300  # 5 minutes for application startup
}

# Auto Scaling Policies Configuration
variable "enable_scaling_policies" {
  description = "Enable automatic scaling policies based on CPU utilization"
  type        = bool
  default     = false  # Disabled by default for cost control in dev
}

variable "user_data" {
  description = "User data script for EC2 instances"
  type        = string
  default     = <<-EOF
    #!/bin/bash
    # EC2 Configuration with Ansible Automation from GitHub
    
    # Update system packages first
    yum update -y
    
    # Install essential packages including Git and Python
    yum install -y \
        httpd \
        amazon-cloudwatch-agent \
        awscli \
        python3 \
        python3-pip \
        git \
        wget \
        curl \
        unzip \
        vim \
        nano \
        htop \
        tree \
        jq
    
    # Install Ansible via pip (latest version)
    pip3 install --upgrade pip
    pip3 install ansible boto3 botocore requests
    
    # Create ansible directory structure
    mkdir -p /opt/ansible/{inventory,files,templates}
    cd /opt/ansible
    
    # Set up basic ansible configuration
    cat > /opt/ansible/ansible.cfg << 'ANSIBLE_CFG'
[defaults]
inventory = ./inventory/hosts
remote_user = ec2-user
private_key_file = ~/.ssh/id_rsa
host_key_checking = False
retry_files_enabled = False
gathering = smart
fact_caching = memory
stdout_callback = yaml
stderr_callback = yaml
log_path = /var/log/ansible.log

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
pipelining = True
ANSIBLE_CFG
    
    # Create basic inventory
    cat > /opt/ansible/inventory/hosts << 'INVENTORY'
[local]
localhost ansible_connection=local

[webservers]
localhost ansible_connection=local

[all:vars]
ansible_python_interpreter=/usr/bin/python3
INVENTORY
    
    # Get instance metadata
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
    REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
    PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
    
    # Create script to sync from GitHub
    cat > /opt/ansible/sync-from-github.sh << 'GITHUB_SCRIPT'
#!/bin/bash
# Script to download only Ansible folder from GitHub

GITHUB_REPO="https://github.com/NaserRaoofi/ec2-failover-automation.git"
GITHUB_BRANCH="main"
ANSIBLE_DIR="/opt/ansible"
TEMP_DIR="/tmp/ansible-github-$(date +%Y%m%d-%H%M%S)"

echo "$(date): Starting GitHub sync for ansible folder only..." >> /var/log/ansible-github.log

# Create temporary directory
mkdir -p "$TEMP_DIR"

# Use sparse-checkout to download only the ansible/ folder (more efficient)
echo "$(date): Downloading ansible folder from $GITHUB_REPO..." >> /var/log/ansible-github.log
cd "$TEMP_DIR"

if git clone --no-checkout --depth=1 -b $GITHUB_BRANCH "$GITHUB_REPO" repo; then
    cd repo
    git sparse-checkout init --cone
    git sparse-checkout set ansible
    git checkout
    
    echo "$(date): Ansible folder downloaded successfully" >> /var/log/ansible-github.log
    
    # Copy ansible structure to /opt/ansible
    if [ -d "ansible/playbooks" ]; then
        cp -r ansible/playbooks "$ANSIBLE_DIR/"
        echo "$(date): Playbooks copied from GitHub" >> /var/log/ansible-github.log
    fi
    
    if [ -d "ansible/roles" ]; then
        cp -r ansible/roles "$ANSIBLE_DIR/"
        echo "$(date): Roles copied from GitHub" >> /var/log/ansible-github.log
    fi
    
    if [ -d "ansible/group_vars" ]; then
        cp -r ansible/group_vars "$ANSIBLE_DIR/"
        echo "$(date): Group vars copied from GitHub" >> /var/log/ansible-github.log
    fi
    
    if [ -d "ansible/host_vars" ]; then
        cp -r ansible/host_vars "$ANSIBLE_DIR/"
        echo "$(date): Host vars copied from GitHub" >> /var/log/ansible-github.log
    fi
    
    if [ -d "ansible/files" ]; then
        cp -r ansible/files/* "$ANSIBLE_DIR/files/" 2>/dev/null
        echo "$(date): Files copied from GitHub" >> /var/log/ansible-github.log
    fi
    
    if [ -d "ansible/templates" ]; then
        cp -r ansible/templates/* "$ANSIBLE_DIR/templates/" 2>/dev/null
        echo "$(date): Templates copied from GitHub" >> /var/log/ansible-github.log
    fi
    
    # Update inventory if provided
    if [ -f "ansible/inventory/hosts" ]; then
        cp ansible/inventory/hosts "$ANSIBLE_DIR/inventory/"
        echo "$(date): Inventory updated from GitHub" >> /var/log/ansible-github.log
    fi
    
    # Update ansible.cfg if provided
    if [ -f "ansible/ansible.cfg" ]; then
        cp ansible/ansible.cfg "$ANSIBLE_DIR/"
        echo "$(date): Ansible config updated from GitHub" >> /var/log/ansible-github.log
    fi
    
else
    echo "$(date): Failed to download ansible folder. Using local setup." >> /var/log/ansible-github.log
    # Fallback: try regular clone if sparse-checkout fails
    if git clone -b $GITHUB_BRANCH "$GITHUB_REPO" "$TEMP_DIR/fallback"; then
        if [ -d "$TEMP_DIR/fallback/ansible" ]; then
            cp -r "$TEMP_DIR/fallback/ansible/"* "$ANSIBLE_DIR/" 2>/dev/null
            echo "$(date): Fallback clone successful" >> /var/log/ansible-github.log
        fi
    fi
fi

# Cleanup
cd /
rm -rf "$TEMP_DIR"

echo "$(date): GitHub sync completed" >> /var/log/ansible-github.log
GITHUB_SCRIPT
    
    chmod +x /opt/ansible/sync-from-github.sh
    
    # Create script to run Ansible playbook
    cat > /opt/ansible/run-playbook.sh << 'RUN_SCRIPT'
#!/bin/bash
# Script to run main Ansible playbook

ANSIBLE_DIR="/opt/ansible"
cd "$ANSIBLE_DIR"

echo "$(date): Starting Ansible playbook execution..." >> /var/log/ansible-setup.log

# Check if site.yml exists (from GitHub)
if [ -f "playbooks/site.yml" ]; then
    echo "$(date): Running site.yml playbook..." >> /var/log/ansible-setup.log
    ansible-playbook -i inventory/hosts playbooks/site.yml -v >> /var/log/ansible-setup.log 2>&1
elif [ -f "site.yml" ]; then
    echo "$(date): Running root site.yml playbook..." >> /var/log/ansible-setup.log
    ansible-playbook -i inventory/hosts site.yml -v >> /var/log/ansible-setup.log 2>&1
else
    echo "$(date): No playbook found. Skipping execution." >> /var/log/ansible-setup.log
    # Create a basic Apache setup as fallback
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>EC2 Instance Ready - Ansible Setup Complete</h1>" > /var/www/html/index.html
    echo "OK" > /var/www/html/health
fi

echo "$(date): Ansible playbook execution completed" >> /var/log/ansible-setup.log
RUN_SCRIPT
    
    chmod +x /opt/ansible/run-playbook.sh
    
    # Set proper ownership
    chown -R root:root /opt/ansible
    chmod -R 755 /opt/ansible
    
    # Initial setup logging
    echo "$(date): Ansible installation completed" >> /var/log/ansible-setup.log
    echo "$(date): Instance metadata - ID: $INSTANCE_ID, AZ: $AZ, Region: $REGION, IP: $PRIVATE_IP" >> /var/log/ansible-setup.log
    
    # Execute GitHub sync
    /opt/ansible/sync-from-github.sh
    
    # Run Ansible playbook
    /opt/ansible/run-playbook.sh
    
    # Create cron job for periodic updates (optional)
    cat > /tmp/ansible-cron << 'CRON_JOB'
# Update Ansible from GitHub and run playbook daily at 2 AM
0 2 * * * /opt/ansible/sync-from-github.sh && /opt/ansible/run-playbook.sh
CRON_JOB
    
    crontab /tmp/ansible-cron
    rm /tmp/ansible-cron
    
    # Final logging
    echo "$(date): EC2 instance setup completed - ready for Ansible automation from GitHub" >> /var/log/application.log
    echo "$(date): To use your GitHub repo, edit /opt/ansible/sync-from-github.sh with your repository URL" >> /var/log/ansible-setup.log
  EOF
}

# Load Balancer Configuration
variable "target_port" {
  description = "Port on which targets receive traffic"
  type        = number
  default     = 80
}

variable "target_protocol" {
  description = "Protocol to use for routing traffic to the targets"
  type        = string
  default     = "HTTP"
}

variable "listener_port" {
  description = "Port on which the load balancer is listening"
  type        = number
  default     = 80
}

variable "listener_protocol" {
  description = "Protocol for connections from clients to the load balancer"
  type        = string
  default     = "HTTP"
}

variable "health_check_path" {
  description = "Destination for the health check request"
  type        = string
  default     = "/"
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the load balancer"
  type        = bool
  default     = false
}

# Route 53 Configuration
variable "domain_name" {
  description = "Domain name for Route 53 hosted zone"
  type        = string
  default     = null
}

variable "create_hosted_zone" {
  description = "Whether to create a new hosted zone"
  type        = bool
  default     = true
}

variable "create_www_record" {
  description = "Whether to create a www CNAME record"
  type        = bool
  default     = true
}

variable "enable_health_check" {
  description = "Enable Route 53 health check"
  type        = bool
  default     = true
}

# Monitoring Configuration
variable "alert_email_addresses" {
  description = "List of email addresses to receive alerts"
  type        = list(string)
  default     = []
}

# ELK (OpenSearch) Configuration
variable "enable_elk_stack" {
  description = "Enable ELK (OpenSearch) stack for centralized logging"
  type        = bool
  default     = true
}

variable "opensearch_instance_type" {
  description = "Instance type for OpenSearch data nodes"
  type        = string
  default     = "t3.small.search"
}

variable "opensearch_instance_count" {
  description = "Number of instances in the OpenSearch cluster"
  type        = number
  default     = 2  # Reduced for dev environment
}

variable "opensearch_master_password" {
  description = "Master password for OpenSearch (must be at least 8 characters)"
  type        = string
  sensitive   = true
  default     = "TempPassword123!"  # Change this in production
}

variable "opensearch_volume_size" {
  description = "EBS volume size in GB for OpenSearch"
  type        = number
  default     = 20
}

variable "opensearch_zone_awareness" {
  description = "Enable zone awareness for OpenSearch (requires even number of instances for multi-AZ)"
  type        = bool
  default     = false  # Disabled by default for single node dev setup
}

variable "elk_log_retention_days" {
  description = "CloudWatch log retention in days for ELK"
  type        = number
  default     = 14  # Shorter retention for dev environment
}

# Bastion Host Configuration
variable "enable_bastion" {
  description = "Enable bastion host for secure access to private instances"
  type        = bool
  default     = true
}

variable "enable_bastion_eip" {
  description = "Enable Elastic IP for bastion host (recommended for production)"
  type        = bool
  default     = true
}

variable "bastion_instance_type" {
  description = "Instance type for bastion host"
  type        = string
  default     = "t3.micro"
}

variable "bastion_root_volume_size" {
  description = "Root volume size for bastion host in GB"
  type        = number
  default     = 20
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks allowed to SSH to bastion host (restrict to your IP)"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # WARNING: Restrict this in production!
}
