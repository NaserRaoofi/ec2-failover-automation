# SNS Topic for alerts
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-alerts"
  })
}

# SNS Topic Subscription
resource "aws_sns_topic_subscription" "email_alerts" {
  count = length(var.alert_email_addresses)

  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email_addresses[count.index]
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.load_balancer_name],
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.load_balancer_name],
            ["AWS/ApplicationELB", "HTTPCode_Target_2XX_Count", "LoadBalancer", var.load_balancer_name],
            ["AWS/ApplicationELB", "HTTPCode_Target_4XX_Count", "LoadBalancer", var.load_balancer_name],
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", var.load_balancer_name]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "Load Balancer Metrics"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.autoscaling_group_name],
            ["AWS/EC2", "NetworkIn", "AutoScalingGroupName", var.autoscaling_group_name],
            ["AWS/EC2", "NetworkOut", "AutoScalingGroupName", var.autoscaling_group_name]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "EC2 Instance Metrics"
        }
      }
    ]
  })
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "high_response_time" {
  alarm_name          = "${var.project_name}-high-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "This metric monitors ALB response time"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    LoadBalancer = var.load_balancer_name
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "high_4xx_errors" {
  alarm_name          = "${var.project_name}-high-4xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_Target_4XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "This metric monitors ALB 4xx errors"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    LoadBalancer = var.load_balancer_name
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "high_5xx_errors" {
  alarm_name          = "${var.project_name}-high-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This metric monitors ALB 5xx errors"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    LoadBalancer = var.load_balancer_name
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "unhealthy_targets" {
  alarm_name          = "${var.project_name}-unhealthy-targets"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "This metric monitors healthy target count"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    TargetGroup  = var.target_group_name
    LoadBalancer = var.load_balancer_name
  }

  tags = var.common_tags
}

# Health Check Deep Monitoring Section
# This section provides detailed monitoring for ASG health check issues

# CloudWatch Dashboard for Health Check Debugging
resource "aws_cloudwatch_dashboard" "health_check_debug" {
  dashboard_name = "${var.project_name}-health-check-debug"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", var.target_group_name],
            ["AWS/ApplicationELB", "UnHealthyHostCount", "TargetGroup", var.target_group_name],
            ["AWS/ApplicationELB", "TargetResponseTime", "TargetGroup", var.target_group_name]
          ]
          period = 60  # 1-minute intervals for faster debugging
          stat   = "Average"
          region = var.aws_region
          title  = "ALB Target Health Status"
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/AutoScaling", "GroupDesiredCapacity", "AutoScalingGroupName", var.autoscaling_group_name],
            ["AWS/AutoScaling", "GroupInServiceInstances", "AutoScalingGroupName", var.autoscaling_group_name],
            ["AWS/AutoScaling", "GroupPendingInstances", "AutoScalingGroupName", var.autoscaling_group_name],
            ["AWS/AutoScaling", "GroupTerminatingInstances", "AutoScalingGroupName", var.autoscaling_group_name]
          ]
          period = 60
          stat   = "Average"
          region = var.aws_region
          title  = "Auto Scaling Group Instance States"
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_2XX_Count", "TargetGroup", var.target_group_name],
            ["AWS/ApplicationELB", "HTTPCode_Target_3XX_Count", "TargetGroup", var.target_group_name],
            ["AWS/ApplicationELB", "HTTPCode_Target_4XX_Count", "TargetGroup", var.target_group_name],
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "TargetGroup", var.target_group_name]
          ]
          period = 60
          stat   = "Sum"
          region = var.aws_region
          title  = "Health Check HTTP Response Codes"
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 18
        width  = 24
        height = 6
        properties = {
          query   = <<-EOT
            SOURCE '/aws/autoscaling/groupstatechange'
            | fields @timestamp, message
            | filter message like /Terminating/
            | sort @timestamp desc
            | limit 20
          EOT
          region  = var.aws_region
          title   = "Recent Instance Terminations"
        }
      }
    ]
  })
}

# Critical Health Check Alarms
resource "aws_cloudwatch_metric_alarm" "unhealthy_targets_critical" {
  alarm_name          = "${var.project_name}-unhealthy-targets-critical"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"  # Immediate alert
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"  # 1-minute check
  statistic           = "Average"
  threshold           = "0"
  alarm_description   = "CRITICAL: Instances are failing health checks - potential death loop detected"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
  treat_missing_data  = "breaching"

  dimensions = {
    TargetGroup = var.target_group_name
  }

  tags = merge(var.common_tags, {
    Severity = "Critical"
    Purpose = "HealthCheckMonitoring"
  })
}

resource "aws_cloudwatch_metric_alarm" "rapid_instance_churn" {
  alarm_name          = "${var.project_name}-rapid-instance-churn"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "GroupTerminatingInstances"
  namespace           = "AWS/AutoScaling"
  period              = "300"  # 5-minute window
  statistic           = "Average"
  threshold           = "0"
  alarm_description   = "WARNING: Auto Scaling Group is terminating instances - possible health check issues"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name
  }

  tags = merge(var.common_tags, {
    Severity = "Warning"
    Purpose = "HealthCheckMonitoring"
  })
}

resource "aws_cloudwatch_metric_alarm" "target_response_time_high" {
  alarm_name          = "${var.project_name}-target-response-time-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "5"  # 5 seconds - health check timeout
  alarm_description   = "WARNING: Health check response time is approaching timeout threshold"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    TargetGroup = var.target_group_name
  }

  tags = merge(var.common_tags, {
    Severity = "Warning"
    Purpose = "HealthCheckMonitoring"
  })
}

# Log Groups for Health Check Debugging
resource "aws_cloudwatch_log_group" "asg_state_changes" {
  name              = "/aws/autoscaling/${var.project_name}/state-changes"
  retention_in_days = 7  # Keep for debugging

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-asg-state-logs"
    Purpose = "HealthCheckDebugging"
  })
}

resource "aws_cloudwatch_log_group" "instance_startup_logs" {
  name              = "/aws/ec2/${var.project_name}/startup"
  retention_in_days = 7

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-startup-logs"
    Purpose = "HealthCheckDebugging"
  })
}

# Custom CloudWatch Metric for Health Check Success Rate
resource "aws_cloudwatch_log_metric_filter" "health_check_failures" {
  name           = "${var.project_name}-health-check-failures"
  log_group_name = aws_cloudwatch_log_group.asg_state_changes.name
  pattern        = "[time, request_id, auto_scaling_group_name, activity_id=\"Terminating\", instance_id, description, cause=\"*health check*\"]"

  metric_transformation {
    name      = "HealthCheckFailures"
    namespace = "Custom/${var.project_name}"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "health_check_failure_rate" {
  alarm_name          = "${var.project_name}-health-check-failure-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HealthCheckFailures"
  namespace           = "Custom/${var.project_name}"
  period              = "300"
  statistic           = "Sum"
  threshold           = "3"  # More than 3 failures in 5 minutes
  alarm_description   = "CRITICAL: High rate of health check failures detected - investigate immediately"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  treat_missing_data  = "notBreaching"

  tags = merge(var.common_tags, {
    Severity = "Critical"
    Purpose = "HealthCheckMonitoring"
  })
}

# Enhanced SNS Topic for Health Check Alerts
resource "aws_sns_topic" "health_check_alerts" {
  name = "${var.project_name}-health-check-alerts"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-health-check-alerts"
    Purpose = "HealthCheckDebugging"
  })
}

resource "aws_sns_topic_subscription" "health_check_email_alerts" {
  count = length(var.alert_email_addresses)

  topic_arn = aws_sns_topic.health_check_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email_addresses[count.index]
}
