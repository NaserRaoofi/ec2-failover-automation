output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = aws_sns_topic.alerts.arn
}

output "dashboard_url" {
  description = "URL of the CloudWatch dashboard"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}"
}

output "high_response_time_alarm_arn" {
  description = "ARN of the high response time alarm"
  value       = aws_cloudwatch_metric_alarm.high_response_time.arn
}

output "high_4xx_errors_alarm_arn" {
  description = "ARN of the high 4xx errors alarm"
  value       = aws_cloudwatch_metric_alarm.high_4xx_errors.arn
}

output "high_5xx_errors_alarm_arn" {
  description = "ARN of the high 5xx errors alarm"
  value       = aws_cloudwatch_metric_alarm.high_5xx_errors.arn
}

output "unhealthy_targets_alarm_arn" {
  description = "ARN of the unhealthy targets alarm"
  value       = aws_cloudwatch_metric_alarm.unhealthy_targets.arn
}

# Health Check Debugging Outputs
output "health_check_dashboard_url" {
  description = "URL of the health check debugging dashboard"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.health_check_debug.dashboard_name}"
}

output "health_check_debug_log_group" {
  description = "CloudWatch log group for health check debugging"
  value       = aws_cloudwatch_log_group.asg_state_changes.name
}

output "unhealthy_targets_critical_alarm_arn" {
  description = "ARN of the unhealthy targets critical alarm"
  value       = aws_cloudwatch_metric_alarm.unhealthy_targets_critical.arn
}

output "instance_churn_alarm_arn" {
  description = "ARN of the ASG instance churn alarm"
  value       = aws_cloudwatch_metric_alarm.rapid_instance_churn.arn
}
