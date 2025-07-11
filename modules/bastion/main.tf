# Bastion Host Module - Secure access to private instances

# Security Group for Bastion Host
resource "aws_security_group" "bastion" {
  name_prefix = "${var.project_name}-bastion-"
  vpc_id      = var.vpc_id
  description = "Security group for bastion host - SSH access from specific IPs"

  # SSH access from specific IP ranges (restrict to your office/home IP)
  ingress {
    description = "SSH from allowed IPs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  # Outbound SSH to private subnets
  egress {
    description = "SSH to private instances"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.private_subnet_cidrs
  }

  # HTTPS for package updates
  egress {
    description = "HTTPS outbound"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP for package updates
  egress {
    description = "HTTP outbound"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-bastion-sg"
    Purpose = "BastionHostAccess"
    SecurityLevel = "High"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Launch Template for Bastion Host
resource "aws_launch_template" "bastion" {
  name_prefix   = "${var.project_name}-bastion-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  # IAM instance profile for bastion host
  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  # Network interface configuration
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.bastion.id]
    subnet_id                   = var.public_subnet_ids[0]
    delete_on_termination       = true
  }

  # User data for bastion host setup
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    project_name = var.project_name
    environment  = var.environment
  }))

  # Storage configuration
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.root_volume_size
      volume_type           = var.root_volume_type
      encrypted             = var.enable_ebs_encryption
      delete_on_termination = true
    }
  }

  # Enhanced monitoring
  monitoring {
    enabled = var.enable_detailed_monitoring
  }

  # Instance metadata service configuration
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-bastion-template"
    Purpose = "BastionHostTemplate"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Bastion Host Instance
resource "aws_instance" "bastion" {
  count = var.enable_bastion ? 1 : 0

  # Use launch template
  launch_template {
    id      = aws_launch_template.bastion.id
    version = "$Latest"
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-bastion-${var.environment}"
    Purpose = "BastionHost"
    SecurityLevel = "High"
    Type = "bastion"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Elastic IP for Bastion Host (optional but recommended)
resource "aws_eip" "bastion" {
  count    = var.enable_bastion && var.enable_bastion_eip ? 1 : 0
  instance = aws_instance.bastion[0].id
  domain   = "vpc"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-bastion-eip"
    Purpose = "BastionHostEIP"
  })

  depends_on = [aws_instance.bastion]
}
