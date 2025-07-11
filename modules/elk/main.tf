# ELK Stack Module - Centralized Logging and Analytics

# Use OpenSearch (AWS managed Elasticsearch) for scalability and managed operations
resource "aws_opensearch_domain" "elk" {
  domain_name    = "${var.project_name}-elk"
  engine_version = var.opensearch_version

  # Multi-AZ deployment for high availability
  cluster_config {
    instance_type            = var.instance_type
    instance_count          = var.instance_count
    dedicated_master_enabled = var.enable_dedicated_master
    dedicated_master_type    = var.enable_dedicated_master ? var.master_instance_type : null
    dedicated_master_count   = var.enable_dedicated_master ? var.master_instance_count : null
    zone_awareness_enabled   = var.enable_zone_awareness
    
    dynamic "zone_awareness_config" {
      for_each = var.enable_zone_awareness ? [1] : []
      content {
        availability_zone_count = var.availability_zone_count
      }
    }
  }

  # EBS storage for persistent logging data
  ebs_options {
    ebs_enabled = true
    volume_type = var.volume_type
    volume_size = var.volume_size
    iops        = var.volume_type == "gp3" ? var.volume_iops : null
    throughput  = var.volume_type == "gp3" ? var.volume_throughput : null
  }

  # VPC deployment for security
  vpc_options {
    security_group_ids = [aws_security_group.opensearch.id]
    subnet_ids         = var.enable_zone_awareness ? var.private_subnet_ids : [var.private_subnet_ids[0]]
  }

  # Enable encryption at rest and in transit
  encrypt_at_rest {
    enabled    = true
    kms_key_id = var.kms_key_id
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  # Fine-grained access control for security
  advanced_security_options {
    enabled                        = true
    anonymous_auth_enabled         = false
    internal_user_database_enabled = var.enable_internal_auth
    
    master_user_options {
      master_user_name     = var.master_username
      master_user_password = var.master_password
    }
  }

  # Configure log publishing for operational visibility
  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch_application.arn
    log_type                 = "ES_APPLICATION_LOGS"
    enabled                  = true
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch_slow_logs.arn
    log_type                 = "SEARCH_SLOW_LOGS"
    enabled                  = true
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch_index_slow_logs.arn
    log_type                 = "INDEX_SLOW_LOGS"
    enabled                  = true
  }

  # Automated snapshots for backup
  snapshot_options {
    automated_snapshot_start_hour = var.snapshot_start_hour
  }

  tags = merge(var.common_tags, {
    Name    = "${var.project_name}-opensearch"
    Purpose = "CentralizedLogging"
    Stack   = "ELK"
  })

  depends_on = [aws_iam_service_linked_role.opensearch]
}

# Service-linked role for OpenSearch
resource "aws_iam_service_linked_role" "opensearch" {
  aws_service_name = "es.amazonaws.com"
  description      = "Service-linked role for OpenSearch"
  
  # Handle case where role might already exist
  lifecycle {
    ignore_changes = [aws_service_name]
  }
}

# Security group for OpenSearch access
resource "aws_security_group" "opensearch" {
  name_prefix = "${var.project_name}-opensearch-"
  vpc_id      = var.vpc_id
  description = "Security group for OpenSearch cluster"

  # Allow HTTPS access from application instances
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = var.allowed_security_groups
    description     = "HTTPS access from application instances"
  }

  # Allow OpenSearch API access
  ingress {
    from_port       = 9200
    to_port         = 9200
    protocol        = "tcp"
    security_groups = var.allowed_security_groups
    description     = "OpenSearch API access"
  }

  # Allow Kibana access (if enabled)
  dynamic "ingress" {
    for_each = var.enable_kibana_access ? [1] : []
    content {
      from_port   = 5601
      to_port     = 5601
      protocol    = "tcp"
      cidr_blocks = var.kibana_access_cidrs
      description = "Kibana dashboard access"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-opensearch-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# CloudWatch log groups for OpenSearch logs
resource "aws_cloudwatch_log_group" "opensearch_application" {
  name              = "/aws/opensearch/domains/${var.project_name}-elk/application-logs"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-opensearch-app-logs"
  })
}

resource "aws_cloudwatch_log_group" "opensearch_slow_logs" {
  name              = "/aws/opensearch/domains/${var.project_name}-elk/search-slow-logs"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-opensearch-slow-logs"
  })
}

resource "aws_cloudwatch_log_group" "opensearch_index_slow_logs" {
  name              = "/aws/opensearch/domains/${var.project_name}-elk/index-slow-logs"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-opensearch-index-logs"
  })
}

# CloudWatch log group for application logs
resource "aws_cloudwatch_log_group" "application_logs" {
  name              = "/aws/ec2/${var.project_name}/application"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-application-logs"
  })
}

# CloudWatch log group for system logs
resource "aws_cloudwatch_log_group" "system_logs" {
  name              = "/aws/ec2/${var.project_name}/system"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-system-logs"
  })
}

# CloudWatch log resource access policies for OpenSearch
data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_log_resource_policy" "opensearch_application" {
  policy_name = "${var.project_name}-opensearch-application-policy"

  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "es.amazonaws.com"
        }
        Action = [
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:CreateLogStream"
        ]
        Resource = "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:/aws/opensearch/domains/${var.project_name}-elk/*"
      }
    ]
  })
}

resource "aws_cloudwatch_log_resource_policy" "opensearch_slow_logs" {
  policy_name = "${var.project_name}-opensearch-slow-policy"

  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "es.amazonaws.com"
        }
        Action = [
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:CreateLogStream"
        ]
        Resource = "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:/aws/opensearch/domains/${var.project_name}-elk/*"
      }
    ]
  })
}

resource "aws_cloudwatch_log_resource_policy" "opensearch_index_slow" {
  policy_name = "${var.project_name}-opensearch-index-policy"

  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "es.amazonaws.com"
        }
        Action = [
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:CreateLogStream"
        ]
        Resource = "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:/aws/opensearch/domains/${var.project_name}-elk/*"
      }
    ]
  })
}

# IAM policy for log shipping from EC2 to OpenSearch (reference from centralized IAM module)
# This is now managed in the centralized IAM module for better security governance

# Note: CloudWatch Logs destination to OpenSearch is not directly supported
# Instead, we'll use Fluent Bit or CloudWatch Agent on EC2 instances to ship logs directly
# This provides better performance and more control over log processing

# The log groups are created for EC2 instances to use via CloudWatch Agent
# Logs will be shipped directly from EC2 to OpenSearch using the centralized IAM policies

# CloudWatch alarms for OpenSearch monitoring
resource "aws_cloudwatch_metric_alarm" "opensearch_cluster_status" {
  alarm_name          = "${var.project_name}-opensearch-cluster-status"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ClusterStatus.yellow"
  namespace           = "AWS/ES"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "OpenSearch cluster status is red"
  alarm_actions       = var.sns_topic_arn != null ? [var.sns_topic_arn] : []

  dimensions = {
    DomainName = aws_opensearch_domain.elk.domain_name
    ClientId   = data.aws_caller_identity.current.account_id
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "opensearch_storage_utilization" {
  alarm_name          = "${var.project_name}-opensearch-storage-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "StorageUtilization"
  namespace           = "AWS/ES"
  period              = "300"
  statistic           = "Maximum"
  threshold           = var.storage_utilization_threshold
  alarm_description   = "OpenSearch storage utilization is high"
  alarm_actions       = var.sns_topic_arn != null ? [var.sns_topic_arn] : []

  dimensions = {
    DomainName = aws_opensearch_domain.elk.domain_name
    ClientId   = data.aws_caller_identity.current.account_id
  }

  tags = var.common_tags
}

# Note: Direct CloudWatch log subscription to OpenSearch is not supported
# Instead, EC2 instances will use CloudWatch Agent or Fluent Bit to ship logs directly
# This provides better performance and more granular control over log processing
# The centralized IAM policies in the IAM module provide the necessary permissions
