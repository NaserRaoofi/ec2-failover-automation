# Route 53 Module Outputs - DNS information for other modules

output "hosted_zone_id" {
  description = "ID of the hosted zone"
  value       = local.hosted_zone_id
}

output "hosted_zone_name_servers" {
  description = "Name servers for the hosted zone"
  value       = var.create_hosted_zone ? aws_route53_zone.main[0].name_servers : []
}

output "domain_name" {
  description = "Domain name configured"
  value       = var.domain_name
}

output "www_domain_name" {
  description = "WWW subdomain name"
  value       = var.create_www_record ? "www.${var.domain_name}" : null
}

output "main_record_fqdn" {
  description = "FQDN of the main A record"
  value       = aws_route53_record.main.fqdn
}

output "www_record_fqdn" {
  description = "FQDN of the www A record"
  value       = var.create_www_record ? aws_route53_record.www[0].fqdn : null
}

output "health_check_id" {
  description = "ID of the health check"
  value       = var.enable_health_check ? aws_route53_health_check.main[0].id : null
}

output "health_check_cloudwatch_alarm_arn" {
  description = "ARN of the CloudWatch alarm for health check"
  value       = var.enable_health_check ? aws_cloudwatch_metric_alarm.health_check_failure[0].arn : null
}

# Additional useful outputs
output "hosted_zone_arn" {
  description = "ARN of the hosted zone"
  value       = var.create_hosted_zone ? aws_route53_zone.main[0].arn : null
}

output "dns_validation_options" {
  description = "DNS validation options for certificate verification"
  value = {
    domain_name = var.domain_name
    main_record = aws_route53_record.main.name
    www_record  = var.create_www_record ? aws_route53_record.www[0].name : null
  }
}
