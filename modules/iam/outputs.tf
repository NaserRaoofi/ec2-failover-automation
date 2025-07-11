# Copilot is now acting as: DevSecOps (see copilot_roles/devsecops.md)
# IAM Module Outputs - Security resource references

output "ec2_role_arn" {
  description = "ARN of the IAM role for EC2 instances"
  value       = aws_iam_role.ec2_role.arn
}

output "ec2_role_name" {
  description = "Name of the IAM role for EC2 instances"
  value       = aws_iam_role.ec2_role.name
}

output "instance_profile_arn" {
  description = "ARN of the IAM instance profile"
  value       = aws_iam_instance_profile.ec2_profile.arn
}

output "instance_profile_name" {
  description = "Name of the IAM instance profile"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "instance_profile_id" {
  description = "ID of the IAM instance profile"
  value       = aws_iam_instance_profile.ec2_profile.id
}

# DevSecOps: Output policy ARNs for reference and compliance tracking
output "cloudwatch_policy_arn" {
  description = "ARN of the CloudWatch agent policy"
  value       = aws_iam_role_policy.cloudwatch_agent_policy.id
}

output "enhanced_monitoring_policy_arn" {
  description = "ARN of the enhanced monitoring policy"
  value       = aws_iam_role_policy.enhanced_monitoring_policy.id
}

output "sns_policy_arn" {
  description = "ARN of the SNS publishing policy (if enabled)"
  value       = var.enable_sns_publishing ? aws_iam_role_policy.sns_publish_policy[0].id : null
}
