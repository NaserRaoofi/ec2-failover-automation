# Copilot is now acting as: DevSecOps (see copilot_roles/devsecops.md)
# IAM Module Variables - Security and access control configuration

variable "project_name" {
  description = "Name of the project for IAM resource naming"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*$", var.project_name))
    error_message = "Project name must start with a letter and contain only alphanumeric characters and hyphens."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "common_tags" {
  description = "Common tags to apply to all IAM resources"
  type        = map(string)
  default     = {}
}

variable "enable_sns_publishing" {
  description = "Enable SNS publishing permissions for EC2 instances"
  type        = bool
  default     = false
}

variable "enable_s3_access" {
  description = "Enable S3 access permissions for specific buckets"
  type        = bool
  default     = false
}

variable "s3_bucket_arns" {
  description = "List of S3 bucket ARNs to grant access to"
  type        = list(string)
  default     = []
}

variable "enable_secrets_manager" {
  description = "Enable AWS Secrets Manager access"
  type        = bool
  default     = false
}

variable "secrets_manager_arns" {
  description = "List of Secrets Manager ARNs to grant access to"
  type        = list(string)
  default     = []
}

variable "elk_log_shipping_policy_arn" {
  description = "ARN of the ELK log shipping policy to attach to EC2 role"
  type        = string
  default     = null
}
