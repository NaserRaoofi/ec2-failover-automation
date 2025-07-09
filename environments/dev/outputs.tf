# Networking Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.networking.private_subnet_ids
}

# Load Balancer Outputs - Commented out for simplified deployment
# output "load_balancer_dns_name" {
#   description = "DNS name of the load balancer"
#   value       = module.load_balancer.load_balancer_dns_name
# }
# 
# output "load_balancer_zone_id" {
#   description = "Zone ID of the load balancer"
#   value       = module.load_balancer.load_balancer_zone_id
# }

# EC2 Outputs - Updated for simplified module
output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2.instance_id
}

output "ec2_instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.ec2.instance_public_ip
}

output "ec2_instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = module.ec2.instance_private_ip
}

output "ssh_connection_command" {
  description = "SSH command to connect to the instance"
  value       = module.ec2.ssh_connection_command
}

# Monitoring Outputs - Commented out for simplified deployment
# output "sns_topic_arn" {
#   description = "ARN of the SNS topic for alerts"
#   value       = module.monitoring.sns_topic_arn
# }
# 
# output "dashboard_url" {
#   description = "URL of the CloudWatch dashboard"
#   value       = module.monitoring.dashboard_url
# }
# 
# # Application URL
# output "application_url" {
#   description = "URL to access the application"
#   value       = "http://${module.load_balancer.load_balancer_dns_name}"
# }
