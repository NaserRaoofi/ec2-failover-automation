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

# Load Balancer Module
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
  common_tags               = local.common_tags
}

# EC2 Module
module "ec2" {
  source = "../../modules/ec2"

  project_name        = var.project_name
  environment        = var.environment
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = var.instance_type
  key_name           = var.key_name
  security_group_id  = module.networking.web_security_group_id
  subnet_ids         = module.networking.private_subnet_ids
  target_group_arns  = [module.load_balancer.target_group_arn]
  min_size           = var.min_size
  max_size           = var.max_size
  desired_capacity   = var.desired_capacity
  user_data          = var.user_data
  common_tags        = local.common_tags
}

# Monitoring Module
module "monitoring" {
  source = "../../modules/monitoring"

  project_name            = var.project_name
  environment            = var.environment
  aws_region             = var.aws_region
  load_balancer_name     = module.load_balancer.load_balancer_arn
  target_group_name      = module.load_balancer.target_group_arn
  autoscaling_group_name = module.ec2.autoscaling_group_name
  alert_email_addresses  = var.alert_email_addresses
  common_tags            = local.common_tags
}
