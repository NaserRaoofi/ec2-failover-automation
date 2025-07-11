# Copilot is now acting as: DevOps Engineer (see copilot_roles/devops_engineer.md)
# ELK Stack Module Variables

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where OpenSearch will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for OpenSearch deployment"
  type        = list(string)
}

variable "allowed_security_groups" {
  description = "List of security group IDs allowed to access OpenSearch"
  type        = list(string)
  default     = []
}

variable "opensearch_version" {
  description = "OpenSearch version"
  type        = string
  default     = "OpenSearch_2.3"
}

variable "instance_type" {
  description = "Instance type for OpenSearch data nodes"
  type        = string
  default     = "t3.small.search"
}

variable "instance_count" {
  description = "Number of instances in the OpenSearch cluster"
  type        = number
  default     = 3
}

variable "enable_dedicated_master" {
  description = "Whether to enable dedicated master nodes"
  type        = bool
  default     = false  # Disabled by default for cost savings in smaller clusters
}

variable "master_instance_type" {
  description = "Instance type for OpenSearch master nodes"
  type        = string
  default     = "t3.small.search"
}

variable "master_instance_count" {
  description = "Number of dedicated master nodes"
  type        = number
  default     = 3
}

variable "enable_zone_awareness" {
  description = "Whether to enable zone awareness"
  type        = bool
  default     = true
}

variable "availability_zone_count" {
  description = "Number of availability zones"
  type        = number
  default     = 2
}

variable "volume_type" {
  description = "EBS volume type"
  type        = string
  default     = "gp3"
}

variable "volume_size" {
  description = "EBS volume size in GB"
  type        = number
  default     = 20
}

variable "volume_iops" {
  description = "EBS volume IOPS (for gp3 volumes)"
  type        = number
  default     = 3000
}

variable "volume_throughput" {
  description = "EBS volume throughput in MB/s (for gp3 volumes)"
  type        = number
  default     = 125
}

variable "kms_key_id" {
  description = "KMS key ID for encryption at rest"
  type        = string
  default     = null
}

variable "enable_internal_auth" {
  description = "Whether to enable internal user database"
  type        = bool
  default     = true
}

variable "master_username" {
  description = "Master username for OpenSearch"
  type        = string
  default     = "admin"
}

variable "master_password" {
  description = "Master password for OpenSearch"
  type        = string
  sensitive   = true
}

variable "snapshot_start_hour" {
  description = "Hour to start automated snapshots"
  type        = number
  default     = 23
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}

variable "enable_kibana_access" {
  description = "Whether to enable Kibana dashboard access"
  type        = bool
  default     = false
}

variable "kibana_access_cidrs" {
  description = "CIDR blocks allowed to access Kibana"
  type        = list(string)
  default     = []
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for CloudWatch alarms"
  type        = string
  default     = null
}

variable "storage_utilization_threshold" {
  description = "Storage utilization threshold for alarms (percentage)"
  type        = number
  default     = 85
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
