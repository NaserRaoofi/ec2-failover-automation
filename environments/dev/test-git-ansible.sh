#!/bin/bash
# Test script to verify Git-based Ansible configuration works

echo "🧪 Testing Git-based Ansible self-configuration..."

# Test 1: Apply current infrastructure
echo "📋 Step 1: Applying Terraform configuration..."
terraform plan -out=tfplan

# Test 2: Check if we can apply safely
echo "📋 Step 2: Reviewing what will be updated..."
echo "This will update the user_data script to use Git-based Ansible configuration"
echo ""
echo "🔍 Key changes:"
echo "✅ Health check setup remains immediate (critical for ASG)"
echo "✅ Ansible configuration now pulls from Git repository"
echo "✅ Always uses latest playbooks and roles"
echo "✅ Version controlled configuration management"
echo ""

read -p "🤔 Do you want to apply these changes? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 Applying changes..."
    terraform apply tfplan
    
    # Wait for new instance to come up
    echo "⏳ Waiting for new instance to be healthy..."
    sleep 30
    
    # Get new instance details
    echo "📊 Checking new instance status..."
    
    # Test the health endpoint
    LOAD_BALANCER_DNS=$(terraform output -raw load_balancer_dns_name 2>/dev/null || echo "not available")
    if [ "$LOAD_BALANCER_DNS" != "not available" ]; then
        echo "🌐 Testing health endpoint via load balancer..."
        curl -s "http://$LOAD_BALANCER_DNS/health" || echo "❌ Health check failed"
        
        echo "🌐 Testing config info page..."
        curl -s "http://$LOAD_BALANCER_DNS/config-info.html" | grep -o '<title>.*</title>' || echo "❌ Config page not ready yet"
    fi
    
    echo "✅ Deployment completed!"
    echo "📝 Check /var/log/startup.log on the instance for detailed configuration logs"
else
    echo "❌ Deployment cancelled"
    rm -f tfplan
fi
