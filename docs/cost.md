# 💰 AWS Cost Estimation

This document tracks the estimated monthly costs for the EC2 Failover Automation infrastructure across different environments and configurations.

## 📊 Current Configuration Cost Breakdown

### **Development Environment (Current Setup)**
*Last Updated: 2025-07-10*
*Region: us-east-1*
*Configuration: VPC + Load Balancer + EC2 + No Route 53*

| Resource | Type | Quantity | Unit Cost | Monthly Cost | Notes |
|----------|------|----------|-----------|--------------|-------|
| **EC2 Instance** | t3.micro | 1 | $0.0104/hour | **$7.59** | Free tier eligible (750h/month) |
| **EBS Volume** | gp3 8GB | 1 | $0.08/GB/month | **$0.64** | Root volume |
| **Application Load Balancer** | ALB | 1 | $16.20/month | **$16.20** | Base cost |
| **ALB Data Processing** | Per GB | ~1GB | $0.008/GB | **$0.01** | Estimated light traffic |
| **VPC NAT Gateway** | Standard | 2 | $32.40/month each | **$64.80** | High availability (2 AZs) |
| **NAT Gateway Data** | Per GB | ~1GB | $0.045/GB | **$0.09** | Estimated outbound traffic |
| **Elastic IP** | EIP | 2 | $3.65/month each | **$7.30** | For NAT Gateways |
| **Route 53** | Hosted Zone | 0 | $0.50/month | **$0.00** | Disabled (domain_name = null) |

### **💵 Total Monthly Cost: ~$96.63**

*Note: EC2 cost is $0.00 if using AWS Free Tier (first 12 months)*

---

## 🔄 Cost Optimization Options

### **Option 1: Single AZ (Cost Reduction)**
- Remove 1 NAT Gateway: **-$36.05/month**
- Remove 1 Elastic IP: **-$3.65/month**
- **New Total: ~$56.93/month**
- ⚠️ **Trade-off**: Reduced high availability

### **Option 2: NAT Instance vs NAT Gateway**
- Replace NAT Gateways with t3.nano NAT instances: **-$57.21/month**
- **New Total: ~$39.42/month**
- ⚠️ **Trade-off**: More management overhead, lower performance

### **Option 3: Public Subnet EC2 (Maximum Savings)**
- Remove NAT Gateways and EIPs: **-$72.14/month**
- Move EC2 to public subnet with direct internet access
- **New Total: ~$24.49/month**
- ⚠️ **Trade-off**: Reduced security (direct internet exposure)

---

## 📈 Production Environment Estimates

### **Production Setup (High Availability)**
*Estimated configuration with Route 53 and monitoring*

| Resource | Quantity | Monthly Cost | Notes |
|----------|----------|--------------|-------|
| EC2 Instances (t3.small) | 2 | **$30.37** | Multi-AZ deployment |
| EBS Volumes (gp3) | 2 × 20GB | **$3.20** | Larger root volumes |
| Application Load Balancer | 1 | **$16.20** | Same as dev |
| ALB Data Processing | ~10GB | **$0.08** | Higher traffic |
| NAT Gateways | 2 | **$64.80** | High availability |
| NAT Gateway Data | ~10GB | **$0.90** | Higher outbound traffic |
| Elastic IPs | 2 | **$7.30** | For NAT Gateways |
| **Route 53** | 1 hosted zone | **$0.50** | Custom domain |
| Route 53 Queries | ~1M queries | **$0.40** | DNS queries |
| CloudWatch Alarms | ~10 alarms | **$1.00** | Monitoring |

### **💵 Production Total: ~$124.75/month**

---

## 🎯 Free Tier Benefits (First 12 Months)

### **AWS Free Tier Inclusions:**
- ✅ **EC2**: 750 hours/month of t2.micro or t3.micro
- ✅ **EBS**: 30GB of General Purpose SSD storage
- ✅ **Data Transfer**: 1GB outbound per month
- ❌ **Load Balancer**: Not included in free tier
- ❌ **NAT Gateway**: Not included in free tier

### **Free Tier Savings:**
- **EC2 Instance**: **-$7.59/month** (if using t3.micro)
- **EBS Storage**: **-$2.40/month** (up to 30GB)
- **With Free Tier Total: ~$86.64/month**

---

## 💡 Cost Monitoring Recommendations

### **CloudWatch Billing Alerts:**
1. Set up billing alert at **$50/month**
2. Set up billing alert at **$100/month**
3. Monitor daily spend trends

### **Cost Allocation Tags:**
- All resources tagged with:
  - `Project: ec2-failover`
  - `Environment: dev/prod`
  - `ManagedBy: Terraform`

### **Regular Reviews:**
- Weekly cost review during active development
- Monthly cost optimization analysis
- Quarterly architecture review for cost efficiency

---

## 🔧 Cost Control Measures

### **Automatic Shutdown (Development):**
```bash
# Schedule EC2 instance shutdown (weekdays only)
# Potential savings: ~30% on EC2 costs
```

### **Spot Instances (Non-Critical Workloads):**
- Potential savings: **60-90%** on EC2 costs
- Only suitable for fault-tolerant applications

### **Reserved Instances (Production):**
- 1-year term: **~30% savings**
- 3-year term: **~50% savings**
- Only commit after stable usage patterns

---

## 📋 Final Cost Summary Tables

### **Development Environment - Service Cost Summary**
*Current Configuration: VPC + Load Balancer + EC2 + No Route 53*

| AWS Service | Resource Count | Monthly Cost | Annual Cost | Notes |
|-------------|----------------|--------------|-------------|--------|
| **EC2** | 1 × t3.micro | **$7.59** | **$91.08** | Free tier: $0.00 (first year) |
| **EBS** | 1 × 8GB gp3 | **$0.64** | **$7.68** | Free tier: $0.00 (first year) |
| **Load Balancer** | 1 × ALB | **$16.21** | **$194.52** | No free tier |
| **VPC** | 1 × NAT Gateway × 2 | **$64.80** | **$777.60** | No free tier |
| **Elastic IP** | 2 × EIP | **$7.30** | **$87.60** | No free tier |
| **Route 53** | 0 × Hosted Zone | **$0.00** | **$0.00** | Disabled |
| **Data Transfer** | Minimal usage | **$0.09** | **$1.08** | Estimated |

### **💰 Development Environment Totals**

| Billing Scenario | Monthly Cost | Annual Cost | Cost Breakdown |
|------------------|--------------|-------------|----------------|
| **With AWS Free Tier** | **$88.64** | **$1,063.68** | No EC2/EBS charges (first year) |
| **Without Free Tier** | **$96.63** | **$1,159.56** | Full pricing after year 1 |
| **Optimized (Single AZ)** | **$56.93** | **$683.16** | Remove 1 NAT Gateway + EIP |
| **Maximum Savings** | **$24.49** | **$293.88** | Public subnet deployment |

---

### **Production Environment - Service Cost Summary**
*Estimated Configuration: VPC + Load Balancer + EC2 × 2 + Route 53 + Monitoring*

| AWS Service | Resource Count | Monthly Cost | Annual Cost | Notes |
|-------------|----------------|--------------|-------------|--------|
| **EC2** | 2 × t3.small | **$30.37** | **$364.44** | Multi-AZ deployment |
| **EBS** | 2 × 20GB gp3 | **$3.20** | **$38.40** | Larger production volumes |
| **Load Balancer** | 1 × ALB | **$16.28** | **$195.36** | Higher traffic processing |
| **VPC** | 2 × NAT Gateway | **$64.80** | **$777.60** | High availability |
| **Elastic IP** | 2 × EIP | **$7.30** | **$87.60** | For NAT Gateways |
| **Route 53** | 1 × Hosted Zone | **$0.90** | **$10.80** | Custom domain + queries |
| **CloudWatch** | 10 × Alarms | **$1.00** | **$12.00** | Monitoring & alerting |
| **Data Transfer** | Higher usage | **$0.90** | **$10.80** | Production traffic |

### **💰 Production Environment Totals**

| Configuration | Monthly Cost | Annual Cost | Use Case |
|---------------|--------------|-------------|----------|
| **Standard Production** | **$124.75** | **$1,497.00** | Full features + monitoring |
| **Production (No Monitoring)** | **$123.75** | **$1,485.00** | Basic production setup |
| **Production + Reserved Instances** | **$87.33** | **$1,047.96** | 30% savings with 1-year commitment |

---

### **🧪 Testing Environment (Single AZ - Cost Optimized)**

| AWS Service | Resource Count | Hourly Cost | 4-Hour Test | 8-Hour Test | Notes |
|-------------|----------------|-------------|-------------|-------------|--------|
| **EC2** | 1 × t3.micro | $0.0104 | **$0.04** | **$0.08** | Free tier: $0.00 |
| **EBS** | 1 × 8GB gp3 | $0.0001 | **$0.00** | **$0.00** | Free tier: $0.00 |
| **Load Balancer** | 1 × ALB | $0.0225 | **$0.09** | **$0.18** | No free tier |
| **VPC** | 1 × NAT Gateway | $0.045 | **$0.18** | **$0.36** | Single AZ only |
| **Elastic IP** | 1 × EIP | $0.005 | **$0.02** | **$0.04** | Single AZ only |
| **Route 53** | 0 × Hosted Zone | $0.000 | **$0.00** | **$0.00** | Disabled |
| **Data Transfer** | Minimal | $0.001 | **$0.00** | **$0.01** | Estimated |

### **💰 Testing Environment Totals**

| Test Duration | Total Cost | With Free Tier | Use Case |
|---------------|------------|----------------|----------|
| **1 Hour Test** | **$0.08** | **$0.05** | Quick validation |
| **4 Hour Test** | **$0.32** | **$0.29** | Thorough testing |
| **8 Hour Test** | **$0.64** | **$0.54** | Extended testing |
| **24 Hour Test** | **$1.93** | **$1.61** | Overnight testing |

**⚠️ Note**: These are HOURLY costs - you only pay for the time resources are running!

---

## ⚠️ Important Notes

1. **Estimates Only**: Actual costs may vary based on usage patterns
2. **Data Transfer**: Costs increase significantly with high traffic
3. **Region Variance**: Prices vary by AWS region
4. **Free Tier**: Only available for first 12 months of AWS account
5. **Hidden Costs**: Consider data transfer between AZs, API calls, etc.

---

*Last Updated: 2025-07-10 by AWS Architect*
*Next Review: When configuration changes are made*
