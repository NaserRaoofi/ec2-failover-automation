# Auto Scaling Module Variables - Scaling and high availability configuration

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "launch_template_id" {
  description = "ID of the Launch Template to use for instances"
  type        = string
}

variable "launch_template_version" {
  description = "Version of the Launch Template to use"
  type        = string
  default     = "$Latest"
}

variable "subnet_ids" {
  description = "List of subnet IDs for Auto Scaling Group (multi-AZ deployment)"
  type        = list(string)
}

variable "target_group_arns" {
  description = "List of target group ARNs to associate with the Auto Scaling Group"
  type        = list(string)
  default     = []
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

# Auto Scaling Group Sizing
variable "min_size" {
  description = "Minimum number of instances in the Auto Scaling Group"
  type        = number
  default     = 1  # Minimum for high availability
}

variable "max_size" {
  description = "Maximum number of instances in the Auto Scaling Group"
  type        = number
  default     = 3  # Allow scaling up for high demand
}

variable "desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group"
  type        = number
  default     = 2  # Start with 2 instances across AZs
}

# Instance Refresh Configuration
variable "min_healthy_percentage" {
  description = "Minimum percentage of instances that must remain healthy during instance refresh"
  type        = number
  default     = 50  # Maintain 50% capacity during updates
}

variable "instance_warmup" {
  description = "Time in seconds for instances to warm up during instance refresh"
  type        = number
  default     = 300  # 5 minutes warmup time
}

variable "protect_from_scale_in" {
  description = "Whether instances should be protected from scale-in events"
  type        = bool
  default     = false
}

# Scaling Policies Configuration
variable "enable_scaling_policies" {
  description = "Enable automatic scaling policies based on CPU utilization"
  type        = bool
  default     = false  # Disabled by default for cost control
}

variable "scale_up_cpu_threshold" {
  description = "CPU utilization threshold for scaling up"
  type        = number
  default     = 70  # Scale up when CPU > 70%
}

variable "scale_down_cpu_threshold" {
  description = "CPU utilization threshold for scaling down"
  type        = number
  default     = 30  # Scale down when CPU < 30%
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {}
}
