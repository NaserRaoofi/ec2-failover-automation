# Launch Template Module Outputs - Template resource references

output "launch_template_id" {
  description = "ID of the Launch Template"
  value       = aws_launch_template.main.id
}

output "launch_template_arn" {
  description = "ARN of the Launch Template"
  value       = aws_launch_template.main.arn
}

output "launch_template_name" {
  description = "Name of the Launch Template"
  value       = aws_launch_template.main.name
}

output "launch_template_latest_version" {
  description = "Latest version of the Launch Template"
  value       = aws_launch_template.main.latest_version
}

output "launch_template_default_version" {
  description = "Default version of the Launch Template"
  value       = aws_launch_template.main.default_version
}

# Configuration details for reference
output "instance_type" {
  description = "Instance type used in the launch template"
  value       = var.instance_type
}

output "ami_id" {
  description = "AMI ID used in the launch template"
  value       = var.ami_id
}

output "root_volume_config" {
  description = "Root volume configuration"
  value = {
    type       = var.root_volume_type
    size       = var.root_volume_size
    encrypted  = var.enable_ebs_encryption
    iops       = var.root_volume_type == "gp3" ? var.root_volume_iops : null
    throughput = var.root_volume_type == "gp3" ? var.root_volume_throughput : null
  }
}
