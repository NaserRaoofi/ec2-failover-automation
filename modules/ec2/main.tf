# EC2 Module - Auto Scaling Group for High Availability and Automatic Failover

# Use Launch Template for better flexibility and versioning
# Launch templates support the latest EC2 features and allow for easier updates
resource "aws_launch_template" "main" {
  name_prefix   = "${var.project_name}-template-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  # Use multiple subnets for high availability
  vpc_security_group_ids = [var.security_group_id]

  # IAM instance profile for secure AWS service access
  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  # Enable detailed monitoring for ASG instances
  # Critical for health checks and scaling decisions
  monitoring {
    enabled = var.enable_detailed_monitoring
  }

  # Use GP3 for better price/performance ratio
  # GP3 provides 3,000 IOPS baseline vs GP2's burst model
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_type           = "gp3"
      volume_size           = var.root_volume_size
      encrypted             = true  # Always encrypt EBS volumes
      delete_on_termination = true
    }
  }

  # User data for consistent initialization
  user_data = base64encode(var.user_data)

  # Comprehensive tagging strategy
  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, {
      Name = "${var.project_name}-asg-instance"
      Backup = var.backup_enabled ? "true" : "false"
      Monitoring = var.enable_detailed_monitoring ? "enhanced" : "basic"
      LaunchedBy = "AutoScalingGroup"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(var.common_tags, {
      Name = "${var.project_name}-asg-volume"
    })
  }

  # Use latest template version for updates
  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-launch-template"
  })
}

# Auto Scaling Group functionality has been moved to a separate module
# This module now focuses solely on Launch Template configuration


