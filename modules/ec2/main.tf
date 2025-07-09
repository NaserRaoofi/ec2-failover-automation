# Copilot is now acting as: AWS Architect (see copilot_roles/aws_architect.md)
# EC2 Module - Simplified for basic instance creation

# Basic EC2 Instance
resource "aws_instance" "main" {
  ami                     = var.ami_id
  instance_type           = var.instance_type
  key_name                = var.key_name
  subnet_id               = var.subnet_id
  vpc_security_group_ids  = [var.security_group_id]
  
  # AWS Architect Decision: Use user_data for initialization
  # This allows for consistent server configuration across deployments
  user_data = var.user_data

  # AWS Architect Decision: Enable detailed monitoring for better observability
  # Cost impact: ~$2.10/month per instance, but provides 1-minute metrics
  monitoring = var.enable_detailed_monitoring

  # AWS Architect Decision: Disable API termination protection for dev/testing
  # Enable this in production environments
  disable_api_termination = var.disable_api_termination

  # AWS Architect Decision: Use GP3 for better price/performance ratio
  # GP3 provides 3,000 IOPS baseline vs GP2's burst model
  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    encrypted             = true  # AWS Architect: Always encrypt EBS volumes
    delete_on_termination = true
    
    tags = merge(var.common_tags, {
      Name = "${var.project_name}-root-volume"
    })
  }

  # AWS Architect Decision: Comprehensive tagging strategy
  # Enables proper cost allocation, automation, and governance
  tags = merge(var.common_tags, {
    Name = "${var.project_name}-instance"
    # AWS Architect: Add operational tags for better management
    Backup = var.backup_enabled ? "true" : "false"
    Monitoring = var.enable_detailed_monitoring ? "enhanced" : "basic"
  })

  # AWS Architect Decision: Use create_before_destroy for blue-green deployments
  lifecycle {
    create_before_destroy = true
  }
}

# AWS Architect Decision: Optional Elastic IP for static IP requirement
# Only create if specifically requested to avoid unnecessary costs
resource "aws_eip" "main" {
  count = var.associate_public_ip ? 1 : 0
  
  instance = aws_instance.main.id
  domain   = "vpc"
  
  tags = merge(var.common_tags, {
    Name = "${var.project_name}-eip"
  })
  
  # AWS Architect: Ensure proper cleanup order
  depends_on = [aws_instance.main]
}
