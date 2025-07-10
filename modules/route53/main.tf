# Copilot is now acting as: AWS Architect (see copilot_roles/aws_architect.md)
# Route 53 Module - DNS management for load balancer integration

# Data source for existing hosted zone (if using existing domain)
data "aws_route53_zone" "main" {
  count = var.create_hosted_zone ? 0 : 1
  name  = var.domain_name
}

# Create new hosted zone (if creating new domain)
resource "aws_route53_zone" "main" {
  count = var.create_hosted_zone ? 1 : 0
  name  = var.domain_name

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-hosted-zone"
  })
}

# Get the hosted zone ID (either from existing or newly created)
locals {
  hosted_zone_id = var.create_hosted_zone ? aws_route53_zone.main[0].zone_id : data.aws_route53_zone.main[0].zone_id
}

# A record for the main domain pointing to load balancer
resource "aws_route53_record" "main" {
  zone_id = local.hosted_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.load_balancer_dns_name
    zone_id                = var.load_balancer_zone_id
    evaluate_target_health = true
  }
}

# A record for www subdomain pointing to load balancer
resource "aws_route53_record" "www" {
  count   = var.create_www_record ? 1 : 0
  zone_id = local.hosted_zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.load_balancer_dns_name
    zone_id                = var.load_balancer_zone_id
    evaluate_target_health = true
  }
}

# Health check for the main domain (optional)
resource "aws_route53_health_check" "main" {
  count                            = var.enable_health_check ? 1 : 0
  fqdn                            = var.domain_name
  port                            = var.health_check_port
  type                            = "HTTPS_STR_MATCH"
  resource_path                   = var.health_check_path
  failure_threshold               = "3"
  request_interval                = "30"
  search_string                   = var.health_check_string
  insufficient_data_health_status = "Unhealthy"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-health-check"
  })
}

# CloudWatch alarm for health check failures
resource "aws_cloudwatch_metric_alarm" "health_check_failure" {
  count               = var.enable_health_check ? 1 : 0
  alarm_name          = "${var.project_name}-domain-health-check-failure"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "1"
  alarm_description   = "This metric monitors domain health check status"
  alarm_actions       = var.sns_topic_arn != null ? [var.sns_topic_arn] : []

  dimensions = {
    HealthCheckId = aws_route53_health_check.main[0].id
  }

  tags = var.common_tags
}
