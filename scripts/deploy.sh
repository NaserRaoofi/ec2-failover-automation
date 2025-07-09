#!/bin/bash

# Deployment script for EC2 Failover Automation
# Usage: ./deploy.sh <environment>

set -e

ENVIRONMENT=${1:-dev}
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_DIR="$PROJECT_ROOT/environments/$ENVIRONMENT"

echo "🚀 Deploying EC2 Failover Automation to $ENVIRONMENT environment..."

# Check if environment directory exists
if [ ! -d "$ENV_DIR" ]; then
    echo "❌ Environment directory $ENV_DIR does not exist!"
    exit 1
fi

# Change to environment directory
cd "$ENV_DIR"

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    echo "⚠️  terraform.tfvars not found. Please create it from terraform.tfvars.example"
    echo "   cp terraform.tfvars.example terraform.tfvars"
    echo "   # Edit terraform.tfvars with your values"
    exit 1
fi

# Initialize Terraform
echo "🔧 Initializing Terraform..."
terraform init

# Validate Terraform configuration
echo "✅ Validating Terraform configuration..."
terraform validate

# Plan deployment
echo "📋 Planning deployment..."
terraform plan -out=tfplan

# Ask for confirmation
echo "🤔 Do you want to apply these changes? (y/N)"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "🚀 Applying changes..."
    terraform apply tfplan
    
    echo "✅ Deployment completed successfully!"
    echo "🌐 Application URL: $(terraform output -raw application_url)"
    echo "📊 Dashboard URL: $(terraform output -raw dashboard_url)"
else
    echo "❌ Deployment cancelled."
    rm -f tfplan
fi
