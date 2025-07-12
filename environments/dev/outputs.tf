# DevOps Environment Outputs

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

# ELK Stack Outputs - COMMENTED OUT FOR HEALTH CHECK DEBUGGING
# output "opensearch_endpoint" {
#   description = "OpenSearch cluster endpoint"
#   value       = var.enable_elk_stack && length(module.elk) > 0 ? module.elk[0].opensearch_endpoint : null
# }

# output "opensearch_dashboard_endpoint" {
#   description = "OpenSearch Dashboards endpoint URL"
#   value       = var.enable_elk_stack && length(module.elk) > 0 ? module.elk[0].opensearch_dashboard_endpoint : null
# }

# output "opensearch_domain_endpoint" {
#   description = "OpenSearch domain HTTPS endpoint"
#   value       = var.enable_elk_stack && length(module.elk) > 0 ? module.elk[0].opensearch_domain_endpoint : null
# }

# output "application_log_group_name" {
#   description = "CloudWatch log group for application logs"
#   value       = var.enable_elk_stack && length(module.elk) > 0 ? module.elk[0].application_log_group_name : null
# }

# output "system_log_group_name" {
#   description = "CloudWatch log group for system logs"
#   value       = var.enable_elk_stack && length(module.elk) > 0 ? module.elk[0].system_log_group_name : null
# }

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

# Bastion Host Outputs
output "bastion_instance_id" {
  description = "ID of the bastion host instance"
  value       = module.bastion.bastion_instance_id
}

output "bastion_public_ip" {
  description = "Public IP address of the bastion host"
  value       = module.bastion.bastion_public_ip
}

output "bastion_elastic_ip" {
  description = "Elastic IP address of the bastion host"
  value       = module.bastion.bastion_elastic_ip
}

output "bastion_security_group_id" {
  description = "ID of the bastion host security group"
  value       = module.bastion.bastion_security_group_id
}

output "ssh_connection_command" {
  description = "SSH command to connect to bastion host"
  value       = module.bastion.ssh_connection_command
}

# Health Check Debugging Outputs
output "health_check_dashboard_url" {
  description = "🔍 URL to Health Check Debugging Dashboard"
  value       = module.monitoring.health_check_dashboard_url
}

output "main_dashboard_url" {
  description = "📊 URL to Main CloudWatch Dashboard"
  value       = module.monitoring.dashboard_url
}

output "health_check_debug_log_group" {
  description = "📝 CloudWatch Log Group for Health Check Debugging"
  value       = module.monitoring.health_check_debug_log_group
}

# Alert and Monitoring Outputs
output "sns_alerts_topic" {
  description = "📧 SNS Topic ARN for receiving alerts"
  value       = module.monitoring.sns_topic_arn
}
