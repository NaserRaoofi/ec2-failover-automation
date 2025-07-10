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
  target_instance_ids       = [module.ec2.instance_id]
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

# EC2 Module - Updated for simplified configuration
module "ec2" {
  source = "../../modules/ec2"

  project_name        = var.project_name
  environment        = var.environment
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = var.instance_type
  key_name           = var.key_name
  security_group_id  = module.networking.web_security_group_id
  subnet_id          = module.networking.private_subnet_ids[0]  # Use first private subnet
  user_data          = var.user_data
  common_tags        = local.common_tags
  
  # Optional configurations
  enable_detailed_monitoring = var.enable_detailed_monitoring
  root_volume_size          = var.root_volume_size
  associate_public_ip       = var.associate_public_ip
}

# Monitoring Module - Commented out for simplified EC2 deployment
# module "monitoring" {
#   source = "../../modules/monitoring"
# 
#   project_name            = var.project_name
#   environment            = var.environment
#   aws_region             = var.aws_region
#   load_balancer_name     = module.load_balancer.load_balancer_arn
#   target_group_name      = module.load_balancer.target_group_arn
#   autoscaling_group_name = module.ec2.autoscaling_group_name
#   alert_email_addresses  = var.alert_email_addresses
#   common_tags            = local.common_tags
# }
