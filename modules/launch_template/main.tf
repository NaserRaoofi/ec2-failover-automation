# Launch Template Module - Instance Configuration and Template Management

# Use Launch Template for better flexibility and versioning
# Launch templates support the latest EC2 features and allow for easier updates
resource "aws_launch_template" "main" {
  name_prefix   = "${var.project_name}-template-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  # Security configuration
  vpc_security_group_ids = var.security_group_ids

  # IAM instance profile for secure AWS service access
  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  # Enable detailed monitoring for better observability
  # Critical for health checks and scaling decisions
  monitoring {
    enabled = var.enable_detailed_monitoring
  }

  # Use GP3 for better price/performance ratio
  # GP3 provides 3,000 IOPS baseline vs GP2's burst model
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_type           = var.root_volume_type
      volume_size           = var.root_volume_size
      iops                  = var.root_volume_type == "gp3" ? var.root_volume_iops : null
      throughput           = var.root_volume_type == "gp3" ? var.root_volume_throughput : null
      encrypted             = var.enable_ebs_encryption
      delete_on_termination = true
      kms_key_id           = var.kms_key_id
    }
  }

  # User data for consistent initialization
  user_data = base64encode(var.user_data)

  # Instance metadata service configuration
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                = "required"  # Enforce IMDSv2
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  # Comprehensive tagging strategy
  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, {
      Name = "${var.project_name}-instance"
      Backup = var.backup_enabled ? "true" : "false"
      Monitoring = var.enable_detailed_monitoring ? "enhanced" : "basic"
      LaunchedBy = "LaunchTemplate"
      Template = "${var.project_name}-template"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(var.common_tags, {
      Name = "${var.project_name}-volume"
      Encrypted = var.enable_ebs_encryption ? "true" : "false"
    })
  }

  tag_specifications {
    resource_type = "network-interface"
    tags = merge(var.common_tags, {
      Name = "${var.project_name}-eni"
    })
  }

  # Use latest template version for updates
  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-launch-template"
    Purpose = "InstanceConfiguration"
  })
}

# Note: Launch template versions are managed automatically by AWS
# Manual version creation is not needed for Auto Scaling Groups