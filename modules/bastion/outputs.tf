# Bastion Host Module Outputs

output "bastion_instance_id" {
  description = "ID of the bastion host instance"
  value       = var.enable_bastion ? aws_instance.bastion[0].id : null
}

output "bastion_public_ip" {
  description = "Public IP address of the bastion host"
  value       = var.enable_bastion ? aws_instance.bastion[0].public_ip : null
}

output "bastion_private_ip" {
  description = "Private IP address of the bastion host"
  value       = var.enable_bastion ? aws_instance.bastion[0].private_ip : null
}

output "bastion_elastic_ip" {
  description = "Elastic IP address of the bastion host"
  value       = var.enable_bastion && var.enable_bastion_eip ? aws_eip.bastion[0].public_ip : null
}

output "bastion_security_group_id" {
  description = "ID of the bastion host security group"
  value       = aws_security_group.bastion.id
}

output "bastion_dns_name" {
  description = "DNS name of the bastion host"
  value       = var.enable_bastion ? aws_instance.bastion[0].public_dns : null
}

output "ssh_connection_command" {
  description = "SSH command to connect to bastion host"
  value = var.enable_bastion ? (
    var.enable_bastion_eip ? 
    "ssh -i ~/.ssh/${var.key_name}.pem ec2-user@${aws_eip.bastion[0].public_ip}" :
    "ssh -i ~/.ssh/${var.key_name}.pem ec2-user@${aws_instance.bastion[0].public_ip}"
  ) : null
}
