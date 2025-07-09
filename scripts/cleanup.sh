#!/bin/bash

# Cleanup script for EC2 Failover Automation
# Usage: ./cleanup.sh <environment>

set -e

ENVIRONMENT=${1:-dev}
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_DIR="$PROJECT_ROOT/environments/$ENVIRONMENT"

echo "🧹 Cleaning up EC2 Failover Automation in $ENVIRONMENT environment..."

# Check if environment directory exists
if [ ! -d "$ENV_DIR" ]; then
    echo "❌ Environment directory $ENV_DIR does not exist!"
    exit 1
fi

# Change to environment directory
cd "$ENV_DIR"

# Check if Terraform state exists
if [ ! -f "terraform.tfstate" ]; then
    echo "⚠️  No terraform.tfstate found. Nothing to destroy."
    exit 0
fi

# Plan destroy
echo "📋 Planning destruction..."
terraform plan -destroy -out=destroy-plan

# Ask for confirmation
echo "⚠️  This will DESTROY all resources in the $ENVIRONMENT environment!"
echo "🤔 Are you sure you want to proceed? (y/N)"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "💥 Destroying resources..."
    terraform apply destroy-plan
    
    echo "✅ Cleanup completed successfully!"
else
    echo "❌ Cleanup cancelled."
    rm -f destroy-plan
fi
