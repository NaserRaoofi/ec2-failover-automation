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

# Load Balancer Outputs
output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.load_balancer.load_balancer_dns_name
}

output "load_balancer_zone_id" {
  description = "Zone ID of the load balancer"
  value       = module.load_balancer.load_balancer_zone_id
}

# EC2 Outputs
output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.ec2.autoscaling_group_name
}

output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = module.ec2.autoscaling_group_arn
}

# Monitoring Outputs
output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = module.monitoring.sns_topic_arn
}

output "dashboard_url" {
  description = "URL of the CloudWatch dashboard"
  value       = module.monitoring.dashboard_url
}

# Application URL
output "application_url" {
  description = "URL to access the application"
  value       = "http://${module.load_balancer.load_balancer_dns_name}"
}
