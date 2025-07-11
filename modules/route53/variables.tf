# Route 53 Module Variables - DNS management configuration

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the hosted zone"
  type        = string
}

variable "create_hosted_zone" {
  description = "Whether to create a new hosted zone or use existing"
  type        = bool
  default     = false  # Use existing domain by default
}

variable "create_www_record" {
  description = "Whether to create a www subdomain record"
  type        = bool
  default     = true
}

variable "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  type        = string
}

variable "load_balancer_zone_id" {
  description = "Zone ID of the load balancer"
  type        = string
}

variable "enable_health_check" {
  description = "Enable Route 53 health check"
  type        = bool
  default     = false  # Disable by default to avoid costs
}

variable "health_check_port" {
  description = "Port for health check"
  type        = number
  default     = 443
}

variable "health_check_path" {
  description = "Path for health check"
  type        = string
  default     = "/"
}

variable "health_check_string" {
  description = "String to search for in health check response"
  type        = string
  default     = "healthy"
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for health check alarms"
  type        = string
  default     = null
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

# Additional Route 53 configuration options
variable "ttl" {
  description = "TTL for DNS records"
  type        = number
  default     = 300  # 5 minutes
}

variable "enable_dnssec" {
  description = "Enable DNSSEC for the hosted zone"
  type        = bool
  default     = false  # Disable by default for simplicity
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS health checks"
  type        = string
  default     = null
}
