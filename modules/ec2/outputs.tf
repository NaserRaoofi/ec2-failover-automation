# Copilot is now acting as: AWS Architect (see copilot_roles/aws_architect.md)
# EC2 Module Outputs - Launch Template Configuration

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

# AWS Architect: Connection information for debugging
output "ssh_connection_command" {
  description = "SSH command pattern for instances (replace INSTANCE_IP with actual IP)"
  value       = var.key_name != null ? "ssh -i ${var.key_name}.pem ec2-user@INSTANCE_IP" : "No key pair specified"
}
