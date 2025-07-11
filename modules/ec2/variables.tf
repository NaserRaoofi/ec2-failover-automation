# Copilot is now acting as: AWS Architect (see copilot_roles/aws_architect.md)
# EC2 Module Variables - Simplified for basic instance creation

variable "project_name" {
  description = "Name of the project"
  type        = string
}

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

variable "security_group_id" {
  description = "Security group ID for EC2 instances"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for EC2 instance placement (deprecated - use subnet_ids)"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "List of subnet IDs for Launch Template (used by Auto Scaling module)"
  type        = list(string)
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name for EC2 instances"
  type        = string
}

variable "user_data" {
  description = "User data script for EC2 instances"
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Environment name"
  type        = string
}

# AWS Architect: Additional variables for production-ready configuration
variable "enable_detailed_monitoring" {
  description = "Enable detailed monitoring (1-minute metrics)"
  type        = bool
  default     = false  # AWS Architect: false for cost optimization in dev
}

variable "disable_api_termination" {
  description = "Disable API termination protection"
  type        = bool
  default     = false  # AWS Architect: Allow termination by default for dev
}

variable "root_volume_size" {
  description = "Size of the root EBS volume in GB"
  type        = number
  default     = 8  # AWS Architect: Minimum for most workloads
}

variable "backup_enabled" {
  description = "Enable automated backups"
  type        = bool
  default     = false  # AWS Architect: Disable by default to reduce costs
}

variable "associate_public_ip" {
  description = "Associate an Elastic IP address"
  type        = bool
  default     = false  # AWS Architect: Avoid unnecessary costs
}

variable "enable_sns_publishing" {
  description = "Enable SNS publishing permissions for EC2 instances"
  type        = bool
  default     = false
}
