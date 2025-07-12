variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "load_balancer_name" {
  description = "Name of the load balancer to monitor"
  type        = string
}

variable "target_group_name" {
  description = "Name of the target group to monitor"
  type        = string
}

variable "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group to monitor"
  type        = string
}

variable "alert_email_addresses" {
  description = "List of email addresses to receive alerts"
  type        = list(string)
  default     = []
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

# Enhanced Health Check Monitoring and Debugging
variable "enable_health_check_dashboard" {
  description = "Create dedicated health check debugging dashboard"
  type        = bool
  default     = true
}

variable "health_check_alarm_threshold" {
  description = "Number of unhealthy targets to trigger alarm"
  type        = number
  default     = 1
}

variable "enable_health_check_logs" {
  description = "Enable detailed health check logging and analysis"
  type        = bool
  default     = true
}
