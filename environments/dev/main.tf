# Configure the AWS Provider
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data source for AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Local values
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Networking Module
module "networking" {
  source = "../../modules/networking"

  project_name           = var.project_name
  environment           = var.environment
  vpc_cidr              = var.vpc_cidr
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  common_tags           = local.common_tags
}

# IAM Module - Centralized IAM resource management
module "iam" {
  source = "../../modules/iam"

  project_name                    = var.project_name
  environment                    = var.environment
  enable_sns_publishing          = var.enable_sns_publishing
  enable_opensearch              = var.enable_elk_stack
  enable_bastion_security_policy = var.enable_bastion
  elk_log_shipping_policy_arn    = ""  # Will be attached separately if ELK is enabled
  common_tags                    = local.common_tags
}

# Load Balancer Module - Now enabled for Route 53 integration
module "load_balancer" {
  source = "../../modules/load_balancer"

  project_name               = var.project_name
  environment               = var.environment
  vpc_id                    = module.networking.vpc_id
  subnet_ids                = module.networking.public_subnet_ids
  security_group_id         = module.networking.alb_security_group_id
  target_port               = var.target_port
  target_protocol           = var.target_protocol
  listener_port             = var.listener_port
  listener_protocol         = var.listener_protocol
  health_check_path         = var.health_check_path
  enable_deletion_protection = var.enable_deletion_protection
  target_instance_ids       = []  # Auto Scaling Group will manage target registration
  common_tags               = local.common_tags
}

# Route 53 Module - DNS management for load balancer (conditional)
module "route53" {
  count  = var.domain_name != null ? 1 : 0
  source = "../../modules/route53"

  project_name               = var.project_name
  environment               = var.environment
  aws_region                = var.aws_region
  domain_name               = var.domain_name
  create_hosted_zone        = var.create_hosted_zone
  create_www_record         = var.create_www_record
  load_balancer_dns_name    = module.load_balancer.dns_name
  load_balancer_zone_id     = module.load_balancer.zone_id
  enable_health_check       = var.enable_health_check
  health_check_path         = var.health_check_path
  common_tags               = local.common_tags
}

# Launch Template Module - Instance Configuration
module "launch_template" {
  source = "../../modules/launch_template"

  project_name                = var.project_name
  environment                = var.environment
  ami_id                     = data.aws_ami.amazon_linux.id
  instance_type              = var.instance_type
  key_name                   = aws_key_pair.main.key_name
  security_group_ids         = [module.networking.web_security_group_id]
  iam_instance_profile_name  = module.iam.instance_profile_name
  user_data                  = var.user_data
  common_tags                = local.common_tags
  
  # Storage and monitoring configurations
  enable_detailed_monitoring = var.enable_detailed_monitoring
  root_volume_size          = var.root_volume_size
  root_volume_type          = var.root_volume_type
  enable_ebs_encryption     = var.enable_ebs_encryption
}

# Auto Scaling Module - High Availability and Automatic Failover
module "autoscaling" {
  source = "../../modules/autoscaling"

  project_name           = var.project_name
  environment           = var.environment
  launch_template_id    = module.launch_template.launch_template_id
  subnet_ids            = module.networking.private_subnet_ids
  target_group_arns     = [module.load_balancer.target_group_arn]
  common_tags           = local.common_tags
  
  # Auto Scaling Group configuration
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period
  
  # Optional scaling features
  enable_scaling_policies = var.enable_scaling_policies
}

# Monitoring Module - Enabled for comprehensive observability
module "monitoring" {
  source = "../../modules/monitoring"

  project_name            = var.project_name
  environment            = var.environment
  aws_region             = var.aws_region
  load_balancer_name     = module.load_balancer.load_balancer_arn
  target_group_name      = module.load_balancer.target_group_arn
  autoscaling_group_name = module.autoscaling.autoscaling_group_name
  alert_email_addresses  = var.alert_email_addresses
  common_tags            = local.common_tags
}

# ELK Stack Module - Centralized Logging and Analytics
module "elk" {
  count  = var.enable_elk_stack ? 1 : 0
  source = "../../modules/elk"

  project_name           = var.project_name
  vpc_id                 = module.networking.vpc_id
  private_subnet_ids     = module.networking.private_subnet_ids
  allowed_security_groups = [
    module.networking.web_security_group_id,
    module.networking.alb_security_group_id
  ]
  
  # OpenSearch configuration
  instance_type         = var.opensearch_instance_type
  instance_count        = var.opensearch_instance_count
  master_password       = var.opensearch_master_password
  volume_size          = var.opensearch_volume_size
  enable_zone_awareness = var.opensearch_zone_awareness
  log_retention_days   = var.elk_log_retention_days
  
  # Note: Using direct log shipping from EC2 instead of CloudWatch Logs destinations
  
  # Use monitoring SNS topic for alerts if available
  sns_topic_arn = length(module.monitoring.sns_topic_arn) > 0 ? module.monitoring.sns_topic_arn : null
  
  common_tags = local.common_tags
}

# Separate IAM policy attachment for ELK log shipping (to avoid count dependency)
resource "aws_iam_role_policy_attachment" "elk_log_shipping_policy_attachment" {
  count      = var.enable_elk_stack ? 1 : 0
  role       = module.iam.ec2_role_name
  policy_arn = module.iam.opensearch_log_shipping_policy_arn
  
  depends_on = [module.iam, module.elk]
}


# Create EC2 Key Pair for SSH access to instances
# This enables troubleshooting, monitoring, and manual intervention when needed
resource "aws_key_pair" "main" {
  key_name   = "${var.project_name}-key"
  public_key = file("${path.module}/ec2-key.pub")  # Use local public key file
  
  tags = merge(local.common_tags, {
    Name        = "${var.project_name}-key"
    Purpose     = "SSH access for troubleshooting and automation"
    Environment = var.environment
  })
  
  lifecycle {
    create_before_destroy = true
  }
}

# Bastion Host Module - Secure access to private instances
module "bastion" {
  source = "../../modules/bastion"

  project_name               = var.project_name
  environment               = var.environment
  vpc_id                    = module.networking.vpc_id
  public_subnet_ids         = module.networking.public_subnet_ids
  private_subnet_cidrs      = var.private_subnet_cidrs
  allowed_ssh_cidrs         = var.allowed_ssh_cidrs
  ami_id                    = data.aws_ami.amazon_linux.id
  instance_type             = var.bastion_instance_type
  key_name                  = aws_key_pair.main.key_name
  iam_instance_profile_name = module.iam.instance_profile_name
  enable_bastion            = var.enable_bastion
  enable_bastion_eip        = var.enable_bastion_eip
  root_volume_size          = var.bastion_root_volume_size
  root_volume_type          = var.root_volume_type
  enable_ebs_encryption     = var.enable_ebs_encryption
  enable_detailed_monitoring = var.enable_detailed_monitoring
  common_tags               = local.common_tags
}

# Additional security group rule to allow SSH from bastion to private instances
# This provides more granular control than VPC-wide access
resource "aws_security_group_rule" "bastion_to_private_ssh" {
  count = var.enable_bastion ? 1 : 0
  
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.bastion.bastion_security_group_id
  security_group_id        = module.networking.web_security_group_id
  description              = "Allow SSH from bastion host to private instances"
}
