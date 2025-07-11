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
  value       = module.load_balancer.dns_name
}

output "load_balancer_zone_id" {
  description = "Zone ID of the load balancer"
  value       = module.load_balancer.zone_id
}

output "load_balancer_arn" {
  description = "ARN of the load balancer"
  value       = module.load_balancer.load_balancer_arn
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = module.load_balancer.target_group_arn
}

# Auto Scaling Group Outputs
output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.autoscaling.autoscaling_group_name
}

output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = module.autoscaling.autoscaling_group_arn
}

output "launch_template_id" {
  description = "ID of the Launch Template"
  value       = module.launch_template.launch_template_id
}

# Application URL
output "application_url" {
  description = "URL to access the application"
  value       = "http://${module.load_balancer.load_balancer_dns_name}"
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

# ELK Stack Outputs
output "opensearch_endpoint" {
  description = "OpenSearch cluster endpoint"
  value       = var.enable_elk_stack && length(module.elk) > 0 ? module.elk[0].opensearch_endpoint : null
}

output "opensearch_kibana_endpoint" {
  description = "OpenSearch Kibana endpoint"
  value       = var.enable_elk_stack && length(module.elk) > 0 ? module.elk[0].opensearch_kibana_endpoint : null
}

output "opensearch_domain_endpoint" {
  description = "OpenSearch domain HTTPS endpoint"
  value       = var.enable_elk_stack && length(module.elk) > 0 ? module.elk[0].opensearch_domain_endpoint : null
}

output "application_log_group_name" {
  description = "CloudWatch log group for application logs"
  value       = var.enable_elk_stack && length(module.elk) > 0 ? module.elk[0].application_log_group_name : null
}

output "system_log_group_name" {
  description = "CloudWatch log group for system logs"
  value       = var.enable_elk_stack && length(module.elk) > 0 ? module.elk[0].system_log_group_name : null
}

# Route 53 Outputs
output "domain_name" {
  description = "Domain name configured"
  value       = var.domain_name
}

output "hosted_zone_id" {
  description = "Route 53 hosted zone ID"
  value       = var.domain_name != null ? module.route53[0].hosted_zone_id : null
}

output "name_servers" {
  description = "Name servers for the hosted zone"
  value       = var.domain_name != null ? module.route53[0].hosted_zone_name_servers : []
}

output "main_record_fqdn" {
  description = "FQDN of the main A record"
  value       = var.domain_name != null ? module.route53[0].main_record_fqdn : null
}

output "www_record_fqdn" {
  description = "FQDN of the www A record"
  value       = var.domain_name != null ? module.route53[0].www_record_fqdn : null
}
