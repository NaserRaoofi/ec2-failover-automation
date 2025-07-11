# Copilot is now acting as: DevSecOps (see copilot_roles/devsecops.md)
# IAM Module - Centralized security and access management

# IAM Role for EC2 instances
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  # DevSecOps: Trust policy allows EC2 service to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-ec2-role"
    Purpose = "EC2InstanceAccess"
    SecurityLevel = "Standard"
  })
}

# DevSecOps: CloudWatch Agent policy - Required for monitoring
resource "aws_iam_role_policy" "cloudwatch_agent_policy" {
  name = "${var.project_name}-cloudwatch-agent-policy"
  role = aws_iam_role.ec2_role.id

  # DevSecOps: Minimal permissions for CloudWatch operations
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "ec2:DescribeVolumes",
          "ec2:DescribeTags",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

# DevSecOps: Enhanced monitoring policy for detailed metrics
resource "aws_iam_role_policy" "enhanced_monitoring_policy" {
  name = "${var.project_name}-enhanced-monitoring-policy"
  role = aws_iam_role.ec2_role.id

  # DevSecOps: Permissions for detailed system metrics and custom metrics
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricData",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeVolumeStatus",
          "ec2:DescribeVolumes",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetHealth"
        ]
        Resource = "*"
      }
    ]
  })
}

# DevSecOps: Optional SNS permissions for custom alerting from EC2 instances
resource "aws_iam_role_policy" "sns_publish_policy" {
  count = var.enable_sns_publishing ? 1 : 0
  name  = "${var.project_name}-sns-publish-policy"
  role  = aws_iam_role.ec2_role.id

  # DevSecOps: Least privilege - only allow publishing to specific topics
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = "arn:aws:sns:*:*:${var.project_name}-*"
      }
    ]
  })
}

# DevSecOps: Systems Manager access for secure instance management
resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# DevSecOps: CloudWatch Agent Server policy attachment
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_server_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# DevSecOps: ELK log shipping policy attachment (conditional)
resource "aws_iam_role_policy_attachment" "elk_log_shipping_policy" {
  count      = var.elk_log_shipping_policy_arn != null ? 1 : 0
  role       = aws_iam_role.ec2_role.name
  policy_arn = var.elk_log_shipping_policy_arn
}

# DevSecOps: Instance profile to attach role to EC2 instances
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-ec2-profile"
    Purpose = "EC2InstanceProfile"
  })
}
