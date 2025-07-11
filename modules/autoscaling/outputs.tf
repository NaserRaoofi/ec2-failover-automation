# Copilot is now acting as: SRE (see copilot_roles/sre.md)
# Auto Scaling Module Outputs - Scaling resource references

output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.arn
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.name
}

output "autoscaling_group_id" {
  description = "ID of the Auto Scaling Group (same as name)"
  value       = aws_autoscaling_group.main.id
}

output "autoscaling_group_min_size" {
  description = "Minimum size of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.min_size
}

output "autoscaling_group_max_size" {
  description = "Maximum size of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.max_size
}

output "autoscaling_group_desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.desired_capacity
}

# SRE: Scaling policy outputs (when enabled)
output "scale_up_policy_arn" {
  description = "ARN of the scale up policy"
  value       = var.enable_scaling_policies ? aws_autoscaling_policy.scale_up[0].arn : null
}

output "scale_down_policy_arn" {
  description = "ARN of the scale down policy"
  value       = var.enable_scaling_policies ? aws_autoscaling_policy.scale_down[0].arn : null
}

# SRE: CloudWatch alarm outputs (when enabled)
output "high_cpu_alarm_arn" {
  description = "ARN of the high CPU alarm"
  value       = var.enable_scaling_policies ? aws_cloudwatch_metric_alarm.high_cpu[0].arn : null
}

output "low_cpu_alarm_arn" {
  description = "ARN of the low CPU alarm"
  value       = var.enable_scaling_policies ? aws_cloudwatch_metric_alarm.low_cpu[0].arn : null
}
