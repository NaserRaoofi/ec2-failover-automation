# IAM Module - Centralized security and access management

# IAM Role for EC2 instances
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  # Trust policy allows EC2 service to assume this role
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

# CloudWatch Agent policy - Required for monitoring
resource "aws_iam_role_policy" "cloudwatch_agent_policy" {
  name = "${var.project_name}-cloudwatch-agent-policy"
  role = aws_iam_role.ec2_role.id

  # Minimal permissions for CloudWatch operations
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

# Enhanced monitoring policy for detailed metrics
resource "aws_iam_role_policy" "enhanced_monitoring_policy" {
  name = "${var.project_name}-enhanced-monitoring-policy"
  role = aws_iam_role.ec2_role.id

  # Permissions for detailed system metrics and custom metrics
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

# Optional SNS permissions for custom alerting from EC2 instances
resource "aws_iam_role_policy" "sns_publish_policy" {
  count = var.enable_sns_publishing ? 1 : 0
  name  = "${var.project_name}-sns-publish-policy"
  role  = aws_iam_role.ec2_role.id

  # Least privilege - only allow publishing to specific topics
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

# Systems Manager access for secure instance management
resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# CloudWatch Agent Server policy attachment
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_server_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# ELK/OpenSearch related IAM resources (centralized security management)

# IAM policy for log shipping from EC2 to OpenSearch
resource "aws_iam_policy" "opensearch_log_shipping" {
  count       = var.enable_opensearch ? 1 : 0
  name        = "${var.project_name}-opensearch-log-shipping"
  description = "Policy for shipping logs from EC2 to OpenSearch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "es:ESHttpPost",
          "es:ESHttpPut", 
          "es:ESHttpGet"
        ]
        Resource = var.opensearch_domain_arn != "" ? "${var.opensearch_domain_arn}/*" : "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream", 
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = [
          "arn:aws:logs:*:*:log-group:/aws/ec2/${var.project_name}/*",
          "arn:aws:logs:*:*:log-group:/aws/opensearch/domains/${var.project_name}-elk/*"
        ]
      }
    ]
  })

  tags = merge(var.common_tags, {
    Purpose = "OpenSearchLogShipping"
    SecurityLevel = "Standard"
  })
}

# IAM role for CloudWatch Logs destination (OpenSearch)
resource "aws_iam_role" "opensearch_log_destination" {
  count = var.enable_opensearch ? 1 : 0
  name  = "${var.project_name}-opensearch-log-destination-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "logs.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Purpose = "OpenSearchLogDestination"
    SecurityLevel = "Standard"
  })
}

# Policy for OpenSearch log destination role
resource "aws_iam_role_policy" "opensearch_log_destination" {
  count = var.enable_opensearch ? 1 : 0
  name  = "${var.project_name}-opensearch-log-destination-policy"
  role  = aws_iam_role.opensearch_log_destination[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "es:ESHttpPost",
          "es:ESHttpPut"
        ]
        Resource = var.opensearch_domain_arn != "" ? "${var.opensearch_domain_arn}/*" : "*"
      }
    ]
  })
}

# ELK log shipping policy attachment (conditional based on variable)
resource "aws_iam_role_policy_attachment" "elk_log_shipping_policy" {
  count      = var.elk_log_shipping_policy_arn != "" ? 1 : 0
  role       = aws_iam_role.ec2_role.name
  policy_arn = var.elk_log_shipping_policy_arn
}

# Instance profile to attach role to EC2 instances
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-ec2-profile"
    Purpose = "EC2InstanceProfile"
  })
}

# Bastion host specific policy for enhanced security operations
resource "aws_iam_role_policy" "bastion_security_policy" {
  count = var.enable_bastion_security_policy ? 1 : 0
  name  = "${var.project_name}-bastion-security-policy"
  role  = aws_iam_role.ec2_role.id

  # Additional permissions for bastion host security operations
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances"
        ]
        Resource = "*"
      }
    ]
  })
}
