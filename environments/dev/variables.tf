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

variable "min_size" {
  description = "Minimum number of instances in Auto Scaling Group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in Auto Scaling Group"
  type        = number
  default     = 2
}

variable "desired_capacity" {
  description = "Desired number of instances in Auto Scaling Group"
  type        = number
  default     = 1
}

variable "user_data" {
  description = "User data script for EC2 instances"
  type        = string
  default     = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello from $(hostname -f)</h1>" > /var/www/html/index.html
    echo "<p>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>" >> /var/www/html/index.html
    echo "<p>Availability Zone: $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</p>" >> /var/www/html/index.html
    echo "<p>Load Balancer Test Page - $(date)</p>" >> /var/www/html/index.html
    EOF
}

# EC2 Additional Configuration
variable "enable_detailed_monitoring" {
  description = "Enable detailed monitoring for EC2 instances"
  type        = bool
  default     = false
}

variable "root_volume_size" {
  description = "Root volume size for EC2 instances"
  type        = number
  default     = 8
}

variable "associate_public_ip" {
  description = "Associate a public IP address with the EC2 instance"
  type        = bool
  default     = false
}

# Load Balancer Configuration
variable "target_port" {
  description = "Target port for load balancer"
  type        = number
  default     = 80
}

variable "target_protocol" {
  description = "Target protocol for load balancer"
  type        = string
  default     = "HTTP"
}

variable "listener_port" {
  description = "Listener port for load balancer"
  type        = number
  default     = 80
}

variable "listener_protocol" {
  description = "Listener protocol for load balancer"
  type        = string
  default     = "HTTP"
}

variable "health_check_path" {
  description = "Health check path for load balancer"
  type        = string
  default     = "/"
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for load balancer"
  type        = bool
  default     = false
}

# Route 53 Configuration
variable "domain_name" {
  description = "Domain name for Route 53 hosted zone"
  type        = string
  default     = null  # AWS Architect: Set to null by default, user must provide
}

variable "create_hosted_zone" {
  description = "Whether to create a new hosted zone"
  type        = bool
  default     = false  # AWS Architect: Use existing domain by default
}

variable "create_www_record" {
  description = "Whether to create www subdomain record"
  type        = bool
  default     = true
}

variable "enable_health_check" {
  description = "Enable Route 53 health check"
  type        = bool
  default     = false  # AWS Architect: Disable by default to avoid costs
}

# Monitoring Configuration
variable "alert_email_addresses" {
  description = "List of email addresses to receive alerts"
  type        = list(string)
  default     = []
}
