# Copilot is now acting as: AWS Architect (see copilot_roles/aws_architect.md)
# EC2 Module Outputs - Simplified for basic instance

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.main.id
}

output "instance_arn" {
  description = "ARN of the EC2 instance"
  value       = aws_instance.main.arn
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.main.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.main.private_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.main.public_dns
}

output "instance_private_dns" {
  description = "Private DNS name of the EC2 instance"
  value       = aws_instance.main.private_dns
}

output "elastic_ip" {
  description = "Elastic IP address (if created)"
  value       = var.associate_public_ip ? aws_eip.main[0].public_ip : null
}

output "elastic_ip_allocation_id" {
  description = "Allocation ID of the Elastic IP (if created)"
  value       = var.associate_public_ip ? aws_eip.main[0].allocation_id : null
}

# AWS Architect: Useful for SSH access and debugging
output "ssh_connection_command" {
  description = "SSH command to connect to the instance"
  value       = var.key_name != null ? "ssh -i ${var.key_name}.pem ec2-user@${aws_instance.main.public_ip}" : "No key pair specified"
}
