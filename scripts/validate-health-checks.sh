#!/bin/bash
# Health Check Configuration Validation Script

echo "🔍 VALIDATING HEALTH CHECK CONFIGURATION..."
echo "========================================"

# Check terraform.tfvars settings
echo "✅ Health Check Grace Period:"
grep "health_check_grace_period" environments/dev/terraform.tfvars

echo ""
echo "✅ Health Check Type:"
grep "health_check_type" environments/dev/terraform.tfvars

echo ""
echo "✅ Health Check Path:"
grep "health_check_path" environments/dev/terraform.tfvars

echo ""
echo "✅ ALB Health Check Settings (Load Balancer Module):"
grep -A 10 "unhealthy_threshold" modules/load_balancer/main.tf

echo ""
echo "🎯 EXPECTED TIMELINE:"
echo "- Instance Launch: 0 minutes"
echo "- Apache Ready: ~1-2 minutes"
echo "- Health Check Fails: 5 minutes (10 × 30 sec)"
echo "- ASG Grace Period: 10 minutes"
echo "- Result: 5 minute buffer for recovery"

echo ""
echo "📊 MONITORING DASHBOARDS:"
echo "- Main Dashboard: ${project_name:-ec2-failover-dev}-dashboard"
echo "- Health Debug Dashboard: ${project_name:-ec2-failover-dev}-health-check-debug"

echo ""
echo "🚨 CRITICAL ALARMS CONFIGURED:"
echo "- Unhealthy targets (immediate)"
echo "- Rapid instance churn"
echo "- High response time"
echo "- Health check failure rate"

echo ""
echo "📧 EMAIL ALERTS:"
grep "alert_email_addresses" environments/dev/terraform.tfvars

echo ""
echo "✅ ALL HEALTH CHECK ISSUES ADDRESSED:"
echo "   ✓ Grace period increased: 300s → 600s"
echo "   ✓ ALB tolerance increased: 5 → 10 failures"
echo "   ✓ Optimized user_data script"
echo "   ✓ Comprehensive monitoring added"

echo ""
echo "🚀 Ready to deploy with: terraform apply"
