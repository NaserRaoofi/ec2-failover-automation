# Copilot is now acting as: DevOps Engineer (see copilot_roles/devops_engineer.md)
# ELK Stack Module - Centralized Logging and Analytics

# DevOps Decision: Use OpenSearch (AWS managed Elasticsearch) for scalability and managed operations
resource "aws_opensearch_domain" "elk" {
  domain_name    = "${var.project_name}-elk"
  engine_version = var.opensearch_version

  # DevOps Decision: Multi-AZ deployment for high availability
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

  # DevOps Decision: EBS storage for persistent logging data
  ebs_options {
    ebs_enabled = true
    volume_type = var.volume_type
    volume_size = var.volume_size
    iops        = var.volume_type == "gp3" ? var.volume_iops : null
    throughput  = var.volume_type == "gp3" ? var.volume_throughput : null
  }

  # DevOps Decision: VPC deployment for security
  vpc_options {
    security_group_ids = [aws_security_group.opensearch.id]
    subnet_ids         = var.private_subnet_ids
  }

  # DevOps Decision: Enable encryption at rest and in transit
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

  # DevOps Decision: Fine-grained access control for security
  advanced_security_options {
    enabled                        = true
    anonymous_auth_enabled         = false
    internal_user_database_enabled = var.enable_internal_auth
    
    master_user_options {
      master_user_name     = var.master_username
      master_user_password = var.master_password
    }
  }

  # DevOps Decision: Configure log publishing for operational visibility
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

  # DevOps Decision: Automated snapshots for backup
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

# DevOps Decision: Service-linked role for OpenSearch
resource "aws_iam_service_linked_role" "opensearch" {
  aws_service_name = "es.amazonaws.com"
  description      = "Service-linked role for OpenSearch"
  
  # Handle case where role might already exist
  lifecycle {
    ignore_changes = [aws_service_name]
  }
}

# DevOps Decision: Security group for OpenSearch access
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

# DevOps Decision: CloudWatch log groups for OpenSearch logs
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

# DevOps Decision: CloudWatch log group for application logs
resource "aws_cloudwatch_log_group" "application_logs" {
  name              = "/aws/ec2/${var.project_name}/application"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-application-logs"
  })
}

# DevOps Decision: CloudWatch log group for system logs
resource "aws_cloudwatch_log_group" "system_logs" {
  name              = "/aws/ec2/${var.project_name}/system"
  retention_in_days = var.log_retention_days

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-system-logs"
  })
}

# DevOps Decision: IAM policy for log shipping from EC2 to OpenSearch
resource "aws_iam_policy" "log_shipping" {
  name        = "${var.project_name}-log-shipping"
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
        Resource = "${aws_opensearch_domain.elk.arn}/*"
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
          aws_cloudwatch_log_group.application_logs.arn,
          aws_cloudwatch_log_group.system_logs.arn,
          "${aws_cloudwatch_log_group.application_logs.arn}:*",
          "${aws_cloudwatch_log_group.system_logs.arn}:*"
        ]
      }
    ]
  })

  tags = var.common_tags
}

# DevOps Decision: CloudWatch Logs subscription filter to ship logs to OpenSearch
resource "aws_cloudwatch_log_destination" "opensearch" {
  name       = "${var.project_name}-opensearch-destination"
  role_arn   = aws_iam_role.log_destination.arn
  target_arn = aws_opensearch_domain.elk.arn

  tags = var.common_tags
}

# DevOps Decision: IAM role for CloudWatch Logs destination
resource "aws_iam_role" "log_destination" {
  name = "${var.project_name}-log-destination-role"

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

  tags = var.common_tags
}

resource "aws_iam_role_policy" "log_destination" {
  name = "${var.project_name}-log-destination-policy"
  role = aws_iam_role.log_destination.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "es:ESHttpPost",
          "es:ESHttpPut"
        ]
        Resource = "${aws_opensearch_domain.elk.arn}/*"
      }
    ]
  })
}

# DevOps Decision: CloudWatch alarms for OpenSearch monitoring
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

data "aws_caller_identity" "current" {}

# DevOps Decision: CloudWatch log subscription filters to ship logs to OpenSearch
resource "aws_cloudwatch_log_subscription_filter" "application_logs" {
  name            = "${var.project_name}-application-logs-filter"
  log_group_name  = aws_cloudwatch_log_group.application_logs.name
  filter_pattern  = ""  # Ship all logs
  destination_arn = aws_cloudwatch_log_destination.opensearch.arn
}

resource "aws_cloudwatch_log_subscription_filter" "system_logs" {
  name            = "${var.project_name}-system-logs-filter"
  log_group_name  = aws_cloudwatch_log_group.system_logs.name
  filter_pattern  = ""  # Ship all logs
  destination_arn = aws_cloudwatch_log_destination.opensearch.arn
}
