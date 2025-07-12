# ASG Health Check Death Loop - Analysis & Solutions

## 🚨 **Current Issue: Auto Scaling Group Death Loop**

Your ASG is experiencing a "death loop" where instances are continuously:
1. **Launched** → **Health Check Fails** → **Terminated** → **New Instance Launched** → **Repeat**

## 🔍 **Root Cause Analysis**

Based on your current configuration, here are the likely causes:

### **1. Health Check Grace Period Too Short**
- **Current**: 300 seconds (5 minutes)
- **Problem**: Your user_data script needs more time to:
  - Update packages (`yum update -y`)
  - Install Apache (`yum install -y httpd`)
  - Start Apache (`systemctl start httpd`)
  - Create health endpoint

### **2. Health Check Configuration Mismatch**
- **ALB Health Check**: Every 30 seconds, 5 consecutive failures = unhealthy (2.5 min)
- **ASG Grace Period**: 5 minutes
- **Gap**: If Apache isn't ready in 2.5 minutes, instance gets marked unhealthy

### **3. Missing Health Check Endpoint**
- **Path**: `/health`
- **Issue**: If the endpoint isn't created fast enough or returns non-200 status

## 🛠️ **Immediate Solutions**

### **Solution 1: Increase Health Check Grace Period**
```terraform
# In environments/dev/terraform.tfvars
# Increase from 300 to 600 seconds (10 minutes)
health_check_grace_period = 600
```

### **Solution 2: Optimize User Data Script**
```bash
#!/bin/bash
# Ultra-fast startup for health check

# Install Apache first (faster than update)
yum install -y httpd

# Create health endpoint IMMEDIATELY
mkdir -p /var/www/html
echo "OK" > /var/www/html/health
echo "<h1>Healthy</h1>" > /var/www/html/index.html

# Start Apache immediately
systemctl start httpd
systemctl enable httpd

# Log success
echo "$(date): Health endpoint ready" >> /var/log/startup.log

# Test locally
curl -f http://localhost/health && echo "$(date): Health check OK" >> /var/log/startup.log

# Update system in background (non-blocking)
nohup yum update -y &
```

### **Solution 3: Adjust ALB Health Check Settings**
```terraform
# In modules/load_balancer/main.tf
health_check {
  enabled             = true
  healthy_threshold   = 2       # Keep at 2
  unhealthy_threshold = 10      # Increase from 5 to 10
  timeout             = 5       # Keep at 5
  interval            = 30      # Keep at 30
  path                = var.health_check_path
  matcher             = "200"
  port                = "traffic-port"
  protocol            = var.target_protocol
}
```

## 📊 **Enhanced Monitoring (Already Added)**

I've added comprehensive health check monitoring that will show you exactly what's happening:

### **New Dashboard: `{project-name}-health-check-debug`**
- **ALB Target Health**: Healthy vs Unhealthy hosts in real-time
- **ASG Instance States**: Desired, InService, Pending, Terminating
- **HTTP Response Codes**: See if health checks return 200, 404, 500, etc.
- **Instance Termination Logs**: Recent terminations with reasons

### **New Critical Alarms**
1. **Unhealthy Targets Critical**: Immediate alert when any target is unhealthy
2. **Rapid Instance Churn**: Alert when instances are being terminated
3. **High Response Time**: Alert when health checks are slow
4. **Health Check Failure Rate**: Alert for high failure patterns

## 🚀 **Recommended Implementation Steps**

### **Step 1: Quick Fix (Apply Now)**
```bash
# Update terraform.tfvars with optimized settings
```

### **Step 2: Deploy Enhanced Monitoring**
```bash
terraform plan   # Review the monitoring changes
terraform apply  # Deploy enhanced monitoring
```

### **Step 3: Monitor Health Check Dashboard**
1. Go to CloudWatch Console
2. Find dashboard: `{project-name}-health-check-debug`
3. Watch in real-time as instances launch

### **Step 4: Check Logs if Still Failing**
```bash
# SSH to failing instance (via bastion)
sudo tail -f /var/log/startup.log
sudo systemctl status httpd
curl http://localhost/health
```

## 📈 **What the Enhanced Monitoring Shows**

### **Healthy Scenario**
- **Healthy Host Count**: 1-2 (stable)
- **Unhealthy Host Count**: 0
- **Instance States**: InService matches Desired
- **HTTP Codes**: Mostly 200s

### **Death Loop Scenario**
- **Healthy Host Count**: 0 (red flag!)
- **Unhealthy Host Count**: 1+ (cycling)
- **Instance States**: High Pending/Terminating
- **HTTP Codes**: 0 responses or lots of 5xx/4xx

## 🔧 **Advanced Debugging Commands**

### **Check Instance Status**
```bash
# From bastion host
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ec2-failover-dev-asg
aws elbv2 describe-target-health --target-group-arn <target-group-arn>
```

### **Monitor Real-time Health**
```bash
# Watch health checks in real-time
watch -n 5 'aws elbv2 describe-target-health --target-group-arn <target-group-arn>'
```

## 🎯 **Expected Outcome**

After implementing these fixes:
1. **Instances launch** and become healthy within 5-10 minutes
2. **No instance terminations** due to health check failures
3. **Stable ASG** with desired capacity maintained
4. **Clear visibility** into health status via dashboard

## 📧 **Alert Configuration**

You'll receive email alerts for:
- Any instance marked unhealthy
- Rapid instance terminations
- Health check response time issues
- High failure rates

The enhanced monitoring will help you:
1. **See exactly when** health checks start failing
2. **Identify patterns** in the failure timing
3. **Debug faster** with detailed logs and metrics
4. **Prevent future issues** with proactive alerts

Ready to deploy these fixes?
