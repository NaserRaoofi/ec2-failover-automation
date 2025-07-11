# Copilot is now acting as: DevOps Engineer (see copilot_roles/devops_engineer.md)
# ELK Stack Module Outputs

output "opensearch_domain_arn" {
  description = "ARN of the OpenSearch domain"
  value       = aws_opensearch_domain.elk.arn
}

output "opensearch_domain_id" {
  description = "Unique identifier for the OpenSearch domain"
  value       = aws_opensearch_domain.elk.domain_id
}

output "opensearch_domain_name" {
  description = "Name of the OpenSearch domain"
  value       = aws_opensearch_domain.elk.domain_name
}

output "opensearch_endpoint" {
  description = "Domain-specific endpoint used to submit index, search, and data upload requests"
  value       = aws_opensearch_domain.elk.endpoint
}

output "opensearch_kibana_endpoint" {
  description = "Domain-specific endpoint for Kibana"
  value       = aws_opensearch_domain.elk.kibana_endpoint
}

output "opensearch_domain_endpoint" {
  description = "Domain-specific endpoint used to submit index, search, and data upload requests"
  value       = "https://${aws_opensearch_domain.elk.endpoint}"
}

output "opensearch_security_group_id" {
  description = "ID of the OpenSearch security group"
  value       = aws_security_group.opensearch.id
}

output "log_shipping_policy_arn" {
  description = "ARN of the IAM policy for log shipping"
  value       = aws_iam_policy.log_shipping.arn
}

output "application_log_group_name" {
  description = "Name of the application CloudWatch log group"
  value       = aws_cloudwatch_log_group.application_logs.name
}

output "application_log_group_arn" {
  description = "ARN of the application CloudWatch log group"
  value       = aws_cloudwatch_log_group.application_logs.arn
}

output "system_log_group_name" {
  description = "Name of the system CloudWatch log group"
  value       = aws_cloudwatch_log_group.system_logs.name
}

output "system_log_group_arn" {
  description = "ARN of the system CloudWatch log group"
  value       = aws_cloudwatch_log_group.system_logs.arn
}

output "opensearch_log_destination_arn" {
  description = "ARN of the CloudWatch log destination for OpenSearch"
  value       = aws_cloudwatch_log_destination.opensearch.arn
}

output "cluster_status_alarm_arn" {
  description = "ARN of the cluster status CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.opensearch_cluster_status.arn
}

output "storage_utilization_alarm_arn" {
  description = "ARN of the storage utilization CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.opensearch_storage_utilization.arn
}
