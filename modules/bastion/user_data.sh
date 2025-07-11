#!/bin/bash
# Bastion Host User Data Script

# Update system packages
yum update -y

# Install essential tools for bastion host
yum install -y \
    htop \
    tmux \
    vim \
    wget \
    curl \
    git \
    awscli \
    jq

# Configure CloudWatch agent for bastion host monitoring
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm

# Create CloudWatch agent configuration for bastion host
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF'
{
    "agent": {
        "metrics_collection_interval": 300,
        "run_as_user": "cwagent"
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/secure",
                        "log_group_name": "/aws/ec2/${project_name}/bastion/secure",
                        "log_stream_name": "{instance_id}-secure",
                        "timestamp_format": "%b %d %H:%M:%S"
                    },
                    {
                        "file_path": "/var/log/messages",
                        "log_group_name": "/aws/ec2/${project_name}/bastion/messages",
                        "log_stream_name": "{instance_id}-messages",
                        "timestamp_format": "%b %d %H:%M:%S"
                    }
                ]
            }
        }
    },
    "metrics": {
        "namespace": "AWS/EC2/Bastion",
        "metrics_collected": {
            "cpu": {
                "measurement": [
                    "cpu_usage_idle",
                    "cpu_usage_iowait",
                    "cpu_usage_user",
                    "cpu_usage_system"
                ],
                "metrics_collection_interval": 300
            },
            "disk": {
                "measurement": [
                    "used_percent"
                ],
                "metrics_collection_interval": 300,
                "resources": [
                    "*"
                ]
            },
            "diskio": {
                "measurement": [
                    "io_time"
                ],
                "metrics_collection_interval": 300,
                "resources": [
                    "*"
                ]
            },
            "mem": {
                "measurement": [
                    "mem_used_percent"
                ],
                "metrics_collection_interval": 300
            },
            "netstat": {
                "measurement": [
                    "tcp_established",
                    "tcp_time_wait"
                ],
                "metrics_collection_interval": 300
            }
        }
    }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
    -s

# Enable CloudWatch agent to start on boot
systemctl enable amazon-cloudwatch-agent

# Configure SSH client settings for easier jump host usage
cat >> /etc/ssh/ssh_config << 'EOF'

# Bastion host specific SSH client configuration
Host 10.0.*
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    ServerAliveInterval 60
    ServerAliveCountMax 3
EOF

# Create a helpful script for connecting to private instances
cat > /home/ec2-user/connect-to-private.sh << 'EOF'
#!/bin/bash
# Helper script to connect to private instances

if [ $# -eq 0 ]; then
    echo "Usage: $0 <private-ip-address>"
    echo "Example: $0 10.0.1.100"
    exit 1
fi

PRIVATE_IP=$1
echo "Connecting to private instance at $PRIVATE_IP..."
ssh -o StrictHostKeyChecking=no ec2-user@$PRIVATE_IP
EOF

chmod +x /home/ec2-user/connect-to-private.sh
chown ec2-user:ec2-user /home/ec2-user/connect-to-private.sh

# Set up SSH key forwarding helper
cat > /home/ec2-user/.ssh/config << 'EOF'
Host *
    ForwardAgent yes
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    ServerAliveInterval 60
    ServerAliveCountMax 3
EOF

chown ec2-user:ec2-user /home/ec2-user/.ssh/config
chmod 600 /home/ec2-user/.ssh/config

# Create helpful aliases
cat >> /home/ec2-user/.bashrc << 'EOF'

# Bastion host aliases
alias ll='ls -la'
alias la='ls -la'
alias l='ls -l'
alias ..='cd ..'
alias ...='cd ../..'

# AWS CLI helper aliases
alias aws-instances='aws ec2 describe-instances --query "Reservations[].Instances[].{InstanceId:InstanceId,State:State.Name,Type:InstanceType,PrivateIP:PrivateIpAddress,PublicIP:PublicIpAddress,Name:Tags[?Key=='\''Name'\''].Value|[0]}" --output table'
alias aws-private-instances='aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query "Reservations[].Instances[?PublicIpAddress==null].{InstanceId:InstanceId,PrivateIP:PrivateIpAddress,Name:Tags[?Key=='\''Name'\''].Value|[0]}" --output table'

echo "Bastion host setup complete!"
echo "Use 'aws-private-instances' to list private instances"
echo "Use './connect-to-private.sh <private-ip>' to connect to private instances"
EOF

# Create a message of the day
cat > /etc/motd << 'EOF'
============================================================
         ${project_name} Bastion Host (${environment})
============================================================

This is a secure bastion host for accessing private instances.

Available commands:
  - aws-instances: List all EC2 instances
  - aws-private-instances: List private instances only
  - ./connect-to-private.sh <IP>: Connect to private instance

Security Notes:
  - This host is monitored via CloudWatch
  - All SSH sessions are logged
  - Use SSH key forwarding for private instance access

============================================================
EOF

# Signal successful completion
/opt/aws/bin/cfn-signal -e $? --stack ${project_name} --resource BastionInstance --region $(curl -s http://169.254.169.254/latest/meta-data/placement/region) || true

echo "Bastion host configuration complete!"
