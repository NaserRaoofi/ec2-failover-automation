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
  default     = "t3.micro"
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

variable "subnet_ids" {
  description = "List of subnet IDs for Auto Scaling Group"
  type        = list(string)
}

variable "target_group_arns" {
  description = "List of target group ARNs for Auto Scaling Group"
  type        = list(string)
  default     = []
}

variable "min_size" {
  description = "Minimum number of instances in Auto Scaling Group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in Auto Scaling Group"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired number of instances in Auto Scaling Group"
  type        = number
  default     = 2
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
