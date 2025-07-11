# Copilot is now acting as: AWS Architect (see copilot_roles/aws_architect.md)
# Launch Template Module Variables - Instance configuration and template settings

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

# Instance Configuration
variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"  # AWS Architect: Free tier eligible
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
  default     = null
}

# Security Configuration
variable "security_group_ids" {
  description = "List of security group IDs for EC2 instances"
  type        = list(string)
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name for EC2 instances"
  type        = string
}

# Storage Configuration
variable "root_volume_type" {
  description = "Type of root EBS volume"
  type        = string
  default     = "gp3"  # AWS Architect: GP3 for better price/performance
}

variable "root_volume_size" {
  description = "Size of the root EBS volume in GB"
  type        = number
  default     = 8  # AWS Architect: Minimum for most workloads
}

variable "root_volume_iops" {
  description = "IOPS for GP3 volumes"
  type        = number
  default     = 3000  # AWS Architect: GP3 baseline
}

variable "root_volume_throughput" {
  description = "Throughput for GP3 volumes in MB/s"
  type        = number
  default     = 125  # AWS Architect: GP3 baseline
}

variable "enable_ebs_encryption" {
  description = "Enable EBS volume encryption"
  type        = bool
  default     = true  # AWS Architect: Always encrypt by default
}

variable "kms_key_id" {
  description = "KMS key ID for EBS encryption (optional)"
  type        = string
  default     = null
}

# Monitoring and Configuration
variable "enable_detailed_monitoring" {
  description = "Enable detailed monitoring (1-minute metrics)"
  type        = bool
  default     = false  # AWS Architect: false for cost optimization in dev
}

variable "user_data" {
  description = "User data script for EC2 instances"
  type        = string
  default     = ""
}

variable "backup_enabled" {
  description = "Enable automated backups"
  type        = bool
  default     = false  # AWS Architect: Disable by default to reduce costs
}

# Template Versioning
variable "create_specific_version" {
  description = "Create a specific version of the launch template"
  type        = bool
  default     = false
}

variable "version_description" {
  description = "Description for the launch template version"
  type        = string
  default     = "Production version"
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {}
}
